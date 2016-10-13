Vehicle Performance by Number of Cylinders
========================================================
author: Shang Ju
date: October 12, 2016
autosize: true



What is this presentation about?
========================================================

This R Markdown presentation is made interactive using Shiny. The viewers of the presentation can change the assumptions underlying what's presented and see the results immediately. 

We used the build-in dataset "mtcars" in R as example. The goal is to examine the relationship between the vehicles' performance (horsepower, fuel efficiency, acceleration) and numbers of cylinders they have.

Instructions on the Interactive Plot
========================================================

- Select the number of cylinders from 4,6,8, and the graph will show you the vehicles accordingly.

- Light blue color represents fast cars and dark blue represents slow cars.

- Horizontal axis shows the fuel efficiency in miles-per-gallon. Vertical axis shows horsepower (how strong the engine is).

Interactive Plot
========================================================

<!--html_preserve--><div class="row">
<div class="col-sm-4">
<form class="well">
<div class="form-group shiny-input-container">
<label class="control-label" for="cyl">
<p>Number of Cylinders</p>
</label>
<div>
<select id="cyl"><option value="4" selected>4</option>
<option value="6">6</option>
<option value="8">8</option></select>
<script type="application/json" data-for="cyl" data-nonempty="">{}</script>
</div>
</div>
</form>
</div>
<div class="col-sm-8">
<div id="outa041155b46105af6" class="shiny-plot-output" style="width: 100% ; height: 400px"></div>
</div>
</div><!--/html_preserve-->

Conclusions
========================================================
As you select different values for the # of cylinders, you can see that the more cylinders a vehicle has, the higher horsepower it tends to have.

Also notice that faster cars tend to have high horsepower, but not necessarily high miles-per-gallon. This is because faster cars (sport cars) tend to be lighter in weight, thus require less gasoline to accelerate.
