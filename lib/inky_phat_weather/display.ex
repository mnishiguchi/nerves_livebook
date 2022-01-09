defmodule InkyPhatWeather.Display do
  @moduledoc false

  defstruct ~w[
    chisel_font
    inky_pid
    last_weather
    last_hello_nerves_measurement
    icons
  ]a

  def refresh_pixels!(state) do
    state = fetch_and_assign_new_data(state)

    clear_pixels(state)
    template(state) |> print_text({10, 12}, :black, [size_x: 2, size_y: 2], state)
    weather_icon(state) |> print_icon(state)
    push_pixels(state)

    state
  end

  ## View

  def template(state) do
    """
    #{current_time_text()}
    #{temperature_f_text(state)} / #{humidity_rh_text(state)} / #{state.last_hello_nerves_measurement.iaq}
    #{weather_description_text(state)}
    #{feels_like_f_text(state)}
    """
  end

  def current_time_text() do
    NaiveDateTime.local_now() |> Calendar.strftime("%Y-%m-%d %I:%M %p")
  end

  def temperature_f_text(%{last_hello_nerves_measurement: measurement}) do
    measurement.temperature_c
    |> Mnishiguchi.Number.convert_temperature_c("F")
    |> Mnishiguchi.Number.float_to_s(0)
    |> Kernel.<>("°F")
  end

  def humidity_rh_text(%{last_hello_nerves_measurement: measurement}) do
    measurement.humidity_rh |> Mnishiguchi.Number.float_to_s(0) |> Kernel.<>(" RH")
  end

  def weather_description_text(%{last_weather: last_weather}) do
    if not is_nil(last_weather) do
      %{"weatherDesc" => weather_desc} = last_weather
      weather_desc |> String.split(",") |> List.first()
    end
  end

  def feels_like_f_text(%{last_weather: last_weather}) do
    if not is_nil(last_weather) do
      %{"FeelsLikeF" => feel_like_f} = last_weather
      "Feels like #{feel_like_f}°F"
    end
  end

  def weather_icon(%{last_weather: last_weather, icons: icons}) do
    if not is_nil(last_weather) do
      %{"weatherDesc" => weather_desc} = last_weather
      icon_name = InkyPhatWeather.Icons.get_icon_name_for_weather(weather_desc)

      if not is_nil(icon_name) do
        Access.fetch!(icons, icon_name)
      end
    end
  end

  ## Data fetching

  def fetch_and_assign_new_data(state) do
    state
    |> maybe_fetch_and_assign_hello_nerves_measurement()
    |> maybe_fetch_and_assign_weather()
  end

  def maybe_fetch_and_assign_hello_nerves_measurement(state) do
    %{state | last_hello_nerves_measurement: HelloNervesSubscriber.measurement()}
  end

  def maybe_fetch_and_assign_weather(state) do
    # Fetch every 30 minutes
    if is_nil(state.last_weather) or DateTime.utc_now().minute in [0, 30] do
      %{state | last_weather: InkyPhatWeather.Weather.get_current_weather()}
    else
      state
    end
  end

  ## Pixel utilities

  def clear_pixels(state) do
    Inky.set_pixels(state.inky_pid, fn _x, _y, _w, _h, _pixels -> :white end, push: :skip)
  end

  def print_text(text, {x, y}, color, opts, state) do
    put_pixels_fun = fn x, y ->
      Inky.set_pixels(state.inky_pid, %{{x, y} => color}, push: :skip)
    end

    Chisel.Renderer.draw_text(text, x, y, state.chisel_font, put_pixels_fun, opts)
  end

  def print_icon(icon_pixels, state) do
    Inky.set_pixels(state.inky_pid, icon_pixels, push: :skip)
  end

  def push_pixels(state) do
    Inky.set_pixels(state.inky_pid, %{}, push: :await)
  end
end
