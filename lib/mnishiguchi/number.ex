defmodule Mnishiguchi.Number do
  @doc """
  Converts a temperature value in Celsius to another unit.

  ## Examples

      iex> convert_temperature(25.0, "F")
      77.0

      iex> convert_temperature(25.0, "K")
      298.15

  """
  def convert_temperature_c(temperature_c, "F"), do: temperature_c * 9.0 / 5.0 + 32.0
  def convert_temperature_c(temperature_c, "K"), do: temperature_c + 273.15

  @doc """
  Converts float to string.

  ## Examples

      iex> float_to_s(12.345)
      "12.35"

      iex> float_to_s(12.345, 5)
      "12.34500"

  """
  def float_to_s(value, decimals \\ 2) do
    :erlang.float_to_binary(value, decimals: decimals)
  end
end
