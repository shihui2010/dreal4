#pragma once

#include <memory>
#include <ostream>
#include <unordered_map>
#include <vector>

#include <nlopt.h>

#include "dreal/symbolic/symbolic.h"
#include "dreal/util/box.h"
#include "dreal/util/nnfizer.h"

namespace dreal {

/// Cached expression class.
class CachedExpression {
 public:
  CachedExpression() = default;
  CachedExpression(Expression e, const Box& box);
  const Box& box() const;
  Environment& mutable_environment();
  const Environment& environment() const;
  double Evaluate(const Environment& env) const;
  const Expression& Differentiate(const Variable& x);

 private:
  Expression expression_;
  Environment environment_;
  const Box* box_{nullptr};
  std::unordered_map<Variable, Expression, hash_value<Variable>> gradient_;

  friend std::ostream& operator<<(std::ostream& os,
                                  const CachedExpression& expression);
};

std::ostream& operator<<(std::ostream& os, const CachedExpression& expression);

/// Wrapper class for nlopt.
class NloptOptimizer {
 public:
  /// Constructs an NloptOptimizer instance given @p algorithm and the
  /// bound @p box.
  ///
  /// @see http://nlopt.readthedocs.io/en/latest/NLopt_Algorithms, for
  /// possible values of NLopt Algorithms.
  NloptOptimizer(nlopt_algorithm algorithm, Box bound, double delta);

  /// Destructor.
  ~NloptOptimizer();

  /// Specifies the objective function.
  void SetMinObjective(const Expression& objective);

  /// Specifies a constraint.
  ///
  /// @note @p formula should be one of the following kinds:
  ///      1) A relational formula (i.e. x >= y)
  ///      2) A negation of a relational formula (i.e. ¬(x > y))
  ///      3) A conjunction of 1) or 2).
  /// @throw std::runtime_error if the above condition does not meet.
  void AddConstraint(const Formula& formula);

  /// Specifies constraints.
  void AddConstraints(const std::vector<Formula>& formulas);

  /// Runs optimization.
  nlopt_result Optimize(std::vector<double>* x, double* opt_f);

  // friend double NloptOptimizerEvaluate(unsigned n, const double* x,
  //                                      double* grad, void* f_data);

 private:
  void AddRelationalConstraint(const Formula& formula);

  nlopt_opt opt_;
  const Box box_;
  const double delta_{0.0};
  CachedExpression objective_;
  std::vector<std::unique_ptr<CachedExpression>> constraints_;
  const Nnfizer nnfizer_{};
};
}  // namespace dreal
