$(document).ready ->
  $(document).on "mouseover", "*[data-url]", (event) ->
    color = $(this).css("fill")
    console.log $(this).attr("data-highest-price-store")

    $("#selected_product .highest-price").append("<span class='glyph general'>w</span>"+$(this).attr("data-highest-price-store")+ " "+ $(this).attr("data-highest-price"))
    $("#selected_product .lowest-price").append("<span class='glyph general'>x</span>"+$(this).attr("data-lowest-price-store")+ " "+ $(this).attr("data-lowest-price"))
    $("#selected_product .name").text($(this).text())
    $("#selected_product").css("color",color)
    $("#selected_product").css("mouse","pointer")

  $(document).on "mouseout", "*[data-url]", (event) ->
    $("#selected_product .name").text("")
    $("#selected_product .highest-price").empty()
    $("#selected_product .lowest-price").empty()

  $(document).on "click", "*[data-url]", (event) ->
    url = $(this).attr('data-url')

    window.location = url
    history.pushState(null, "Pantopol.io", url)
