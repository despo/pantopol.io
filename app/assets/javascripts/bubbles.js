$(document).ready(function() {
  $('.bubble-graph').each(function() {
    width = $(this).css("width").replace(/[^-\d\.]/g, '');
    var diameter = width,
  format = d3.format(",d"),
  color = d3.scale.category10()

    var bubble = d3.layout.pack()
    .sort(null)
    .size([diameter, diameter]);

  var svg = d3.select(this).append("svg")
    .attr("width", diameter)
    .attr("height", diameter)
    .attr("class", "bubble");

  d3.json($(this).attr("data-path"), function(error, root) {
    var node = svg.selectAll(".node")
    .data(bubble.nodes(classes(root))
      .filter(function(d) { return !d.children; }))
    .enter().append("g")
    .attr("class", "node")
    .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });

  node.append("title")
    .text(function(d) { return d.className + ": " + format(d.value); });

  node.append("circle")
    .attr("r", function(d) { return d.r; })
    .style("fill", function(d) { return color(d.packageName); });

  node.append("text")
    .attr("dy", ".3em")
    .style("text-anchor", "middle")
    .text(function(d) { return d.className.substring(0, d.r / 3); });
  });

  function classes(root) {
    var classes = [];

    function recurse(name, node) {
      if (node.children) node.children.forEach(function(child) { recurse(node.name, child); });
      else classes.push({packageName: name, className: node.name, value: node.size*1.5});
    }

    recurse(null, root);
    return {children: classes};
  }

  d3.select(self.frameElement).style("height", diameter + "px");
  });

  $('.cloud').each(function() {
    var fill = d3.scale.category20();
    var current = $('.cloud')
    var width = current.css("width").replace(/[^-\d\.]/g, '');
  var height = current.css("height").replace(/[^-\d\.]/g, '');

  start(width, height);


  function draw(words) {
    d3.select(".cloud").append("svg")
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(600,250)")
    .selectAll("text")
    .data(words)
    .enter().append("text")
    .style("font-size", function(d) { return d.size + "px"; })
    .style("font-family", "Impact")
    .style("fill", function(d, i) { return fill(i); })
    .attr("text-anchor", "middle")
    .attr("data-highest-price", function(d) { return d.highest_price; })
    .attr("data-highest-price-store", function(d) { return d.highest_price_store; })
    .attr("data-lowest-price", function(d) { return d.lowest_price; })
    .attr("data-lowest-price-store", function(d) { return d.lowest_price_store; })
    .attr("data-url", function(d) { return d.url; })
    .attr("transform", function(d) {
      return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
    })
  .text(function(d) { return d.text; });
  }

  function start(width, height) {
    var classes = [];
    var current = $('.cloud')

    d3.json(current.attr("data-path"), function(error, root) {

      function recurse(name, node) {
        var size = node.size;

        if (node.size > 30){
          size =  20;
        } else if (node.size > 10){
          size =  10;
        } else if (node.size > 5) {
          size = 8;
        } else if (node.size < 5) {
          size = 5;
        } else if (node.size < 1) {
          size = 3;
        }

        if (node.children) node.children.forEach(function(child) { recurse(node.name, child); });
        else  {
          classes.push({ text: node.text, size: size + 10, url: node.url, highest_price: node.highest_price, highest_price_store: node.highest_price_store, lowest_price: node.lowest_price, lowest_price_store: node.lowest_price_store});
        }
      }

      recurse(null, root);

      d3.layout.cloud().size([1200, 500])
        .timeInterval(1000)
        .words(classes)
        .padding(2)
        .rotate(function() { return ~~(Math.random() * 5) * 30 - 60; })
        .font("Impact")
        .fontSize(function(d) { return d.size; })
        .on("end", draw)
        .start();


    });
  }

  });
});
