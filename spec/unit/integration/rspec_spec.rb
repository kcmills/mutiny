module Mutiny
  class Integration
    describe RSpec do
      context "inspecting test sets" do
        it "should be able to count tests" do
          in_example_project("calculator") do
            test_set = subject.all_tests

            expect(test_set.size).to eq(6)
            expect(test_set.empty?).to be_falsey
          end
        end

        it "should be able to report that there are no tests" do
          in_example_project("untested_calculator") do
            test_set = subject.all_tests

            expect(test_set.size).to eq(0)
            expect(test_set.empty?).to be_truthy
          end
        end

        it "should be able to filter tests to a single subject" do
          in_example_project("calculator", :require) do
            test_set = subject.tests_for(Subjects::SubjectSet.new([Calculator::Max]))

            expect(test_set.size).to eq(3)
            expect(test_set.empty?).to be_falsey
          end
        end

        it "should be able to filter to nothing when there are no relevant tests" do
          in_example_project("calculator") do
            test_set = subject.tests_for(Subjects::SubjectSet.new([String]))

            expect(test_set.size).to eq(0)
            expect(test_set.empty?).to be_truthy
          end
        end
      end

      context "running test sets" do
        it "should be able to run a passing test set" do
          in_example_project("calculator") do
            test_set = subject.all_tests
            test_run = subject.run(test_set)

            expect(test_run.passed?).to be_truthy
            expect(test_run.failed_tests.empty?).to be_truthy
          end
        end

        it "should be able to run a failing test set" do
          in_example_project("buggy_calculator") do
            test_set = subject.all_tests
            test_run = subject.run(test_set)

            expect(test_run.passed?).to be_falsey
            expect(test_run.failed_tests.locations).to eq([
              "./examples/buggy_calculator/spec/calculator/max_spec.rb:9",
              "./examples/buggy_calculator/spec/calculator/max_spec.rb:13"
            ])
          end
        end

        it "should be able to run an empty test set" do
          in_example_project("untested_calculator") do
            test_set = subject.all_tests
            test_run = subject.run(test_set)

            expect(test_run.passed?).to be_truthy
            expect(test_run.failed_tests.empty?).to be_truthy
          end
        end

        it "should be able to run a partial test set" do
          in_example_project("buggy_calculator") do
            test_set = subject.all_tests
            partial_test_set = test_set.take(1)
            test_run = subject.run(partial_test_set)

            # Note: This would be false if the whole test set was run
            expect(test_run.passed?).to be_truthy
          end
        end
      end

      def in_example_project(example_name, should_require = false)
        in_sub_process do
          $LOAD_PATH << File.join(Dir.pwd, "examples", example_name, "lib")
          Dir.chdir(File.join("examples", example_name))
          require example_name if should_require
          yield
        end
      end
    end
  end
end
