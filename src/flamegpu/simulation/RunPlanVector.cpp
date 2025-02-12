#include "flamegpu/simulation/RunPlanVector.h"
#include "flamegpu/model/ModelDescription.h"

namespace flamegpu {

RunPlanVector::RunPlanVector(const ModelDescription &model, unsigned int initial_length)
    : std::vector<RunPlan>(initial_length, RunPlan(model))
    , randomPropertySeed(std::random_device()())
    , rand(randomPropertySeed)
    , environment(std::make_shared<std::unordered_map<std::string, EnvironmentData::PropData> const>(model.model->environment->properties))
    , allow_0_steps(model.model->exitConditions.size() + model.model->exitConditionCallbacks.size() > 0) {
    this->resize(initial_length, RunPlan(environment, allow_0_steps));
}

RunPlanVector::RunPlanVector(const std::shared_ptr<const std::unordered_map<std::string, EnvironmentData::PropData>> &_environment, const bool _allow_0_steps)
    : std::vector<RunPlan>()
    , randomPropertySeed(std::random_device()())
    , rand(randomPropertySeed)
    , environment(_environment)
    , allow_0_steps(_allow_0_steps) { }
void RunPlanVector::setRandomSimulationSeed(const uint64_t initial_seed, const unsigned int step) {
    uint64_t current_seed = initial_seed;
    for (auto &i : *this) {
        i.setRandomSimulationSeed(current_seed);
        current_seed += step;
    }
}
void RunPlanVector::setSteps(const unsigned int steps) {
    if (steps == 0 && !allow_0_steps) {
        throw exception::OutOfBoundsException("Model description requires atleast 1 exit condition to have unlimited steps, "
            "in RunPlanVector::setSteps()");
    }
    for (auto &i : *this) {
        i.setSteps(steps);
    }
}
void RunPlanVector::setOutputSubdirectory(const std::string &subdir) {
    for (auto &i : *this) {
        i.setOutputSubdirectory(subdir);
    }
}
void RunPlanVector::setRandomPropertySeed(const uint64_t seed) {
    randomPropertySeed = seed;
    rand.seed(randomPropertySeed);
}

uint64_t RunPlanVector::getRandomPropertySeed() {
    return randomPropertySeed;
}

RunPlanVector RunPlanVector::operator+(const RunPlan& rhs) const {
    // This function is defined internally inside both RunPlan and RunPlanVector as it's the only way to both pass CI and have SWIG build
    // Validation
    if (*rhs.environment != *this->environment) {
        THROW exception::InvalidArgument("RunPlan is for a different ModelDescription, "
            "in ::operator+(RunPlanVector, RunPlan)");
    }
    // Operation
    RunPlanVector rtn(*this);
    rtn+=rhs;
    return rtn;
}
RunPlanVector RunPlanVector::operator+(const RunPlanVector& rhs) const {
    // Validation
    if (*rhs.environment != *this->environment) {
        THROW exception::InvalidArgument("RunPlanVectors are for different ModelDescriptions, "
            "in ::operator+(RunPlanVector, RunPlanVector)");
    }
    // Operation
    RunPlanVector rtn(*this);
    rtn+=rhs;
    return rtn;
}
RunPlanVector& RunPlanVector::operator+=(const RunPlan& rhs) {
    // Validation
    if (*rhs.environment != *this->environment) {
        THROW exception::InvalidArgument("RunPlan is for a different ModelDescription, "
            "in ::operator+=(RunPlanVector, RunPlan)");
    }
    // Update shared_ptr to env
    RunPlan rhs_copy = rhs;
    rhs_copy.environment = environment;
    // Operation
    this->push_back(rhs_copy);
    return *this;
}
RunPlanVector& RunPlanVector::operator+=(const RunPlanVector& rhs) {
    // Validation
    if (this == &rhs) {
        return *this*=2;
    }
    if (*rhs.environment != *this->environment) {
        THROW exception::InvalidArgument("RunPlan is for a different ModelDescription, "
            "in ::operator+=(RunPlanVector, RunPlan)");
    }
    // Operation
    this->reserve(size() + rhs.size());
    // Iterate, because insert would require RunPlan::operator==
    for (const auto &i : rhs) {
        // Update shared_ptr to env
        RunPlan i_copy = i;
        i_copy.environment = environment;
        this->push_back(i);
    }
    return *this;
}
RunPlanVector& RunPlanVector::operator*=(const unsigned int rhs) {
    RunPlanVector copy(*this);
    this->clear();
    this->reserve(copy.size() * rhs);
    for (unsigned int i = 0; i < rhs; ++i) {
        // Iterate, because insert would require RunPlan::operator==
        for (const auto &j : copy) {
            this->push_back(j);
        }
    }
    return *this;
}
RunPlanVector RunPlanVector::operator*(const unsigned int rhs) const {
    RunPlanVector rtn(this->environment, this->allow_0_steps);
    rtn.reserve(size() * rhs);
    for (unsigned int i = 0; i < rhs; ++i) {
        // Iterate, because insert would require RunPlan::operator==
        for (const auto &j : *this) {
            rtn.push_back(j);
        }
    }
    return rtn;
}

bool RunPlanVector::operator==(const RunPlanVector& rhs) const {
    if (this == &rhs)
        return true;
    if (this->randomPropertySeed == rhs.randomPropertySeed &&
        this->rand == rhs.rand &&
        this->environment == rhs.environment &&  // Could check the pointed to map matches instead
        this->allow_0_steps == rhs.allow_0_steps &&
        this->size() == rhs.size()) {
        for (size_t i = 0; i < this->size(); ++i) {
            if (!(this->at(i) == rhs.at(i))) {
                return false;
            }
        }
        return true;
    }
    return false;
}
bool RunPlanVector::operator!=(const RunPlanVector& rhs) const {
    return !((*this) == rhs);
}

}  // namespace flamegpu
