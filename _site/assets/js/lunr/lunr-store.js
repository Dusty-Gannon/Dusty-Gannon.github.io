var store = [{
        "title": "Welcome to Jekyll!",
        "excerpt":"code testing     print(\"testing\")      # comments   var &lt;- runif(1)   pnorm(var)   var %*% B + vec(2)  math testing   \\[\\begin{aligned} Y_t &amp;\\sim \\mathcal{N}(\\mu,\\ \\sigma^2)\\\\ \\mathbb{E}(Y_t) = {\\boldsymbol \\beta} \\end{aligned}\\] ","categories": ["jekyll","update"],
        "tags": [],
        "url": "/jekyll/update/welcome-to-jekyll/",
        "teaser": null
      },{
    "title": "Welcome to Jekyll!",
    "excerpt":"code testing     print(\"testing\")      # comments   var &lt;- runif(1)   pnorm(var)   var %*% B + vec(2)  math testing   \\[\\begin{aligned} Y_t &amp;\\sim \\mathcal{N}(\\mu,\\ \\sigma^2)\\\\ \\mathbb{E}(Y_t) = {\\boldsymbol \\beta} \\end{aligned}\\] ","url": "http://localhost:4000/_posts/2023-01-04-welcome-to-jekyll/"
  },{
    "title": null,
    "excerpt":"     404     Page not found :(    The requested page could not be found.   ","url": "http://localhost:4000/404.html"
  },{
    "title": null,
    "excerpt":"Latest Posts  ","url": "http://localhost:4000/_pages/blog/"
  },{
    "title": null,
    "excerpt":"Feel free to email me anytime at dustin.gannon@oregonstate.edu. I will get back to you as soon as possible, but note that, on the weekend, you are just as likely to get through to me by sending up smoke signals in the MacDonald-Dunn forest as you are over email.      ","url": "http://localhost:4000/_pages/contact"
  },{
    "title": "Education",
    "excerpt":"Education Sep 2016 - Mar 2022 : PhD in Ecology, Oregon State University Sep 2020 - Mar 2022 : MS in Statistics, Oregon State University Sep 2011 - May 2015 : BS in Ecosystem Science and Sustainability, Colorado State University Research Interests Statistical ecology, Bayesian statistics, theoretical ecology, time series...","url": "http://localhost:4000/_pages/cv"
  },{
    "title": null,
    "excerpt":"I am an ecologist and statistician interested in fitting theoretical models of populations and ecological communities to data. I currently work as a consulting statistician in the College of Forestry at Oregon State University. Please excuse any lack of content or bugs in the website as I am in the...","url": "http://localhost:4000/"
  },{
    "title": null,
    "excerpt":"var idx = lunr(function () { this.field('title') this.field('excerpt') this.field('categories') this.field('tags') this.ref('id') this.pipeline.remove(lunr.trimmer) for (var item in store) { this.add({ title: store[item].title, excerpt: store[item].excerpt, categories: store[item].categories, tags: store[item].tags, id: item }) } }); $(document).ready(function() { $('input#search').on('keyup', function () { var resultdiv = $('#results'); var query = $(this).val().toLowerCase(); var result = idx.query(function...","url": "http://localhost:4000/assets/js/lunr/lunr-en.js"
  },{
    "title": null,
    "excerpt":"step1list = new Array(); step1list[\"ΦΑΓΙΑ\"] = \"ΦΑ\"; step1list[\"ΦΑΓΙΟΥ\"] = \"ΦΑ\"; step1list[\"ΦΑΓΙΩΝ\"] = \"ΦΑ\"; step1list[\"ΣΚΑΓΙΑ\"] = \"ΣΚΑ\"; step1list[\"ΣΚΑΓΙΟΥ\"] = \"ΣΚΑ\"; step1list[\"ΣΚΑΓΙΩΝ\"] = \"ΣΚΑ\"; step1list[\"ΟΛΟΓΙΟΥ\"] = \"ΟΛΟ\"; step1list[\"ΟΛΟΓΙΑ\"] = \"ΟΛΟ\"; step1list[\"ΟΛΟΓΙΩΝ\"] = \"ΟΛΟ\"; step1list[\"ΣΟΓΙΟΥ\"] = \"ΣΟ\"; step1list[\"ΣΟΓΙΑ\"] = \"ΣΟ\"; step1list[\"ΣΟΓΙΩΝ\"] = \"ΣΟ\"; step1list[\"ΤΑΤΟΓΙΑ\"] = \"ΤΑΤΟ\"; step1list[\"ΤΑΤΟΓΙΟΥ\"] = \"ΤΑΤΟ\"; step1list[\"ΤΑΤΟΓΙΩΝ\"] = \"ΤΑΤΟ\"; step1list[\"ΚΡΕΑΣ\"]...","url": "http://localhost:4000/assets/js/lunr/lunr-gr.js"
  },{
    "title": null,
    "excerpt":"var store = [ {%- for c in site.collections -%} {%- if forloop.last -%} {%- assign l = true -%} {%- endif -%} {%- assign docs = c.docs | where_exp:'doc','doc.search != false' -%} {%- for doc in docs -%} {%- if doc.header.teaser -%} {%- capture teaser -%}{{ doc.header.teaser }}{%- endcapture...","url": "http://localhost:4000/assets/js/lunr/lunr-store.js"
  },{
    "title": null,
    "excerpt":"{% if page.xsl %} {% endif %} {% assign collections = site.collections | where_exp:'collection','collection.output != false' %}{% for collection in collections %}{% assign docs = collection.docs | where_exp:'doc','doc.sitemap != false' %}{% for doc in docs %} {{ doc.url | replace:'/index.html','/' | absolute_url | xml_escape }} {% if doc.last_modified_at or doc.date...","url": "http://localhost:4000/sitemap.xml"
  },{
    "title": null,
    "excerpt":"Sitemap: {{ \"sitemap.xml\" | absolute_url }} ","url": "http://localhost:4000/robots.txt"
  },{
    "title": null,
    "excerpt":"{% if page.xsl %}{% endif %}Jekyll{{ site.time | date_to_xmlschema }}{{ page.url | absolute_url | xml_escape }}{% assign title = site.title | default: site.name %}{% if page.collection != \"posts\" %}{% assign collection = page.collection | capitalize %}{% assign title = title | append: \" | \" | append: collection %}{% endif...","url": "http://localhost:4000/feed.xml"
  }]
