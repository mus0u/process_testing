defmodule ProcessTestingTest do
  use ExUnit.Case

  @tag timeout: :infinity
  describe "parallel_map/2" do
    test "applies the function to each element of the enumerable" do
      function = fn number ->
        Process.sleep(1_000)
        number * 2
      end

      list = Enum.into(1..10_000, [])

      expected_result = Enum.into(2..20_000//2, [])

      # to see how slow this is using sequential map, compare:
      # assert Enum.map(list, function) == expected_result
      assert ProcessTesting.parallel_map(list, function) == expected_result
    end
  end

  describe "multiprocess_reduce/3" do
    test "folds over the enumerable by running each reduction in a separate process" do
      function = fn elem, acc -> elem + acc end

      list = [1, 2, 3, 4, 5]

      assert ProcessTesting.multiprocess_reduce(list, 0, function) == 15
    end
  end
end
