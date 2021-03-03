defmodule Qwixx.ScorecardRow do
  defstruct values: [], locked: false, lock_num: -1

  def new(color) when color in [:red, :yellow], do: new_row(2..12)
  def new(color) when color in [:blue, :green], do: new_row(12..2)

  defp new_row(_low..high = range) do
    values = for x <- range, do: %{val: x, status: :open}
    %__MODULE__{locked: false, values: values, lock_num: high}
  end

  def count_checks(%__MODULE__{} = row),
    do: Enum.count(row.values, fn %{status: status} -> status == :yes end)

  def lock(%__MODULE__{} = row), do: %{row | locked: true}

  def mark!(%__MODULE__{} = row, num) do
    {:ok, row} = mark(row, num)
    row
  end

  def mark(%__MODULE__{} = row, num) do
    with :ok <- validate_mark(row, num) do
      {:ok, row |> do_mark(num) |> maybe_lock()}
    else
      {:invalid, reasons} -> {:error, reasons}
    end
  end

  defp do_mark(row, num) do
    {a, [_ | b]} = Enum.split_while(row.values, fn x -> x.val != num end)

    a = Enum.map(a, fn x -> if x.status == :open, do: %{x | status: :no}, else: x end)
    target = %{status: :yes, val: num}

    %{row | values: a ++ [target] ++ b}
  end

  defp maybe_lock(%__MODULE__{values: values} = row) do
    case List.last(values).status do
      :yes -> %{row | locked: true}
      _ -> row
    end
  end

  ######################################################################
  ## Validation
  ######################################################################

  defp validate_mark(%__MODULE__{} = row, num) do
    reasons = if !row.locked, do: [], else: [:locked]
    reasons = if num_in_row(row, num), do: reasons, else: reasons ++ [:num_out_of_range]
    reasons = if num_is_open(row, num), do: reasons, else: reasons ++ [:num_not_open]
    reasons = if enough_to_lock(row, num), do: reasons ++ [:not_enough_to_lock], else: reasons

    if Enum.empty?(reasons), do: :ok, else: {:invalid, reasons}
  end

  defp num_in_row(%__MODULE__{values: values}, num),
    do: Enum.find(values, fn %{val: v} -> v == num end)

  defp num_is_open(%__MODULE__{values: values} = row, num) do
    !num_in_row(row, num) or
      Enum.find(values, fn %{val: v, status: status} -> v == num and status == :open end)
  end

  defp enough_to_lock(%__MODULE__{} = row, num),
    do: num == row.lock_num and count_checks(row) < 4
end
