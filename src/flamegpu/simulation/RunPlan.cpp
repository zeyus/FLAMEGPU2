#include "flamegpu/simulation/RunPlan.h"
#include "flamegpu/simulation/RunPlanVector.h"

#include "flamegpu/model/ModelDescription.h"

namespace flamegpu {

RunPlan::RunPlan(const ModelDescription &model)
    : RunPlan(std::make_shared<std::unordered_map<std::string, EnvironmentData::PropData> const>(model.model->environment->properties),
      model.model->exitConditions.size() + model.model->exitConditionCallbacks.size() > 0) { }
RunPlan::RunPlan(const std::shared_ptr<const std::unordered_map<std::string, EnvironmentData::PropData>>  &environment, const bool allow_0)
    : random_seed(0)
    , steps(1)
    , environment(environment)
    , allow_0_steps(allow_0) { }

RunPlan& RunPlan::operator=(const RunPlan& other) {
    this->random_seed = other.random_seed;
    this->steps = other.steps;
    this->environment = other.environment;
    this->allow_0_steps = other.allow_0_steps;
    this->output_subdirectory = other.output_subdirectory;
    this->allow_0_steps = other.allow_0_steps;
    for (auto &i : other.property_overrides)
        this->property_overrides.emplace(i.first, detail::Any(i.second));
    return *this;
}
void RunPlan::setRandomSimulationSeed(const uint64_t _random_seed) {
    random_seed = _random_seed;
}
void RunPlan::setSteps(const unsigned int _steps) {
    if (_steps == 0 && !allow_0_steps) {
        throw exception::OutOfBoundsException("Model description requires atleast 1 exit condition to have unlimited steps, "
            "in RunPlan::setSteps()");
    }
    steps = _steps;
}
void RunPlan::setOutputSubdirectory(const std::string &subdir) {
    output_subdirectory = subdir;
}

uint64_t RunPlan::getRandomSimulationSeed() const {
    return random_seed;
}
unsigned int RunPlan::getSteps() const {
    return steps;
}
std::string RunPlan::getOutputSubdirectory() const {
    return output_subdirectory;
}

RunPlanVector RunPlan::operator+(const RunPlan& rhs) const {
    // Validation
    if (*rhs.environment != *this->environment) {
        THROW exception::InvalidArgument("RunPlan is for a different ModelDescription, "
            "in ::operator+(RunPlan, RunPlan)");
    }
    // Operation
    RunPlanVector rtn(this->environment, this->allow_0_steps);
    rtn+=*this;
    rtn+=rhs;
    return rtn;
}
RunPlanVector RunPlan::operator+(const RunPlanVector& rhs) const {
    // This function is defined internally inside both RunPlan and RunPlanVector as it's the only way to both pass CI and have SWIG build
    // Validation
    if (*rhs.environment != *this->environment) {
        THROW exception::InvalidArgument("RunPlan is for a different ModelDescription, "
            "in ::operator+(RunPlan, RunPlanVector)");
    }
    // Operation
    RunPlanVector rtn(rhs);
    rtn+=*this;
    return rtn;
}
RunPlanVector RunPlan::operator*(const unsigned int rhs) const {
    // Operation
    RunPlanVector rtn(this->environment, this->allow_0_steps);
    for (unsigned int i = 0; i < rhs; ++i) {
        rtn+=*this;
    }
    return rtn;
}

bool RunPlan::operator==(const RunPlan& rhs) const {
    if (this == &rhs)
        return true;
    if (this->random_seed == rhs.random_seed &&
        this->steps == rhs.steps &&
        this->property_overrides == rhs.property_overrides &&
        this->environment == rhs.environment &&  // Could check the pointed to map matches instead
        this->allow_0_steps == rhs.allow_0_steps &&
        this->output_subdirectory == rhs.output_subdirectory) {
        return true;
    }
    return false;
}
bool RunPlan::operator!=(const RunPlan& rhs) const {
    return !((*this) == rhs);
}

}  // namespace flamegpu
