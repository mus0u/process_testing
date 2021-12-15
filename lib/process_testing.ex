defmodule ProcessTesting do
  def parallel_map(enumerable, function) do
    pids =
      for item <- enumerable do
        Task.async(fn ->
          function.(item)
        end)
      end

    Enum.map(pids, &Task.await/1)
  end

  def multiprocess_reduce(enumerable, initial_accumulator, reducer_function) do
    reducer_pids =
      for item <- enumerable do
        worker_function = fn ->
          receive do
            {[next_pid | remaining_pids], accumulator} ->
              result = reducer_function.(item, accumulator)
              send(next_pid, {remaining_pids, result})
          end
        end

        spawn(worker_function)
      end

    [first_worker | pids] = reducer_pids ++ [self()]

    send(first_worker, {pids, initial_accumulator})

    receive do
      {[], final_result} -> final_result
    end
  end
end
