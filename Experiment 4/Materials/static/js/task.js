/*
 * Requires:
 *     psiturk.js
 *     utils.js
 */

// Initalize psiturk object
var psiTurk = new PsiTurk(uniqueId, adServerLoc, mode);

var mycondition = condition;
var mycounterbalance = counterbalance;

// All pages to be loaded
var pages = [
    "instructions/instruct.html",
    "stage.html",
    "postquestionnaire.html"
];

psiTurk.preloadPages(pages);

var instructionPages = [ // add as a list as many pages as you like
    "instructions/instruct.html"
];


/********************
* Experiment      *
********************/

var MyExperiment = function() {

    var error_message = "<h1>Oops!</h1><p>Something went wrong submitting your "
        + "HIT. This might happen if you lose your internet connection. Press "
        + "the button to resubmit.</p><button id='resubmit'>Resubmit</button>";
    
    /* 3 values for the 3 different stories each user will see.
     * 0 means the case where all x, y, z must be known for the action to make
     * sense. 1 means the case where only one of x, y, and z need to be known
     * for the action to make sense.
     *
     * IMPORTANT: for half of the N workers use [0, 1, 0]. For the other half
     *            use [1, 0, 1]!!
     */
    // var cases = [0, 1, 0]; // use this for N/2 of the workers
    var cases = [1, 0, 1]; // use this for N/2 of the workers

    /* storyNum[i] refers to the story number for the ith trial */
    var storyNum = _.shuffle([0, 1, 2]);

    /* Random names fitted in the story */
    var names = _.shuffle(['Jacob', 'David', 'Alex', 'Matt']);

    /* Returns an array of possible explanations for worker to rate.
     * 
     * Parameters:
     *      story   -   0: food allergy
     *                  1: police arrest
     *                  2: entering house
     *      name    - randomized name of person in story
     *      caseNum -   0: all x, y, z must be known for best explanation
     *                  1: only one of x, y, and z need to be known
     */
    var getExplanations = function(story, name, caseNum) {
        var output = [];
        if (story == 0) {
            if (caseNum) {
                return [
                    name + " <b>didn't know</b> that the goat cheese contained benzatrate.",
                    name + " <b>didn't know</b> that the bell pepper contained benzatrate.",
                    name + " <b>didn't know</b> that the bacon contained benzatrate.",
                    name + " <b>didn't know</b> that the goat cheese contained benzatrate or that the bell pepper contained benzatrate.",
                    name + " <b>didn't know</b> that the goat cheese contained benzatrate or that the bacon contained benzatrate.",
                    name + " <b>didn't know</b> that the bell pepper contained benzatrate or that the bacon contained benzatrate.",
                    name + " <b>didn't know</b> that the goat cheese contained benzatrate, or that the bell pepper contained benzatrate, or that the bacon contained benzatrate.",
                    name + " <b>knew</b> that the goat cheese contained benzatrate, and that the bell pepper contained benzatrate, and that the bacon contained benzatrate."
                ];
            }
            return [
                name + " <b>knew</b> that the goat cheese contained benzatrate.",
                name + " <b>knew</b> that the bell pepper contained benzatrate.",
                name + " <b>knew</b> that the bacon contained benzatrate.",
                name + " <b>knew</b> that the goat cheese contained benzatrate and that the bell pepper contained benzatrate.",
                name + " <b>knew</b> that the goat cheese contained benzatrate and that the bacon contained benzatrate.",
                name + " <b>knew</b> that the bell pepper contained benzatrate and that the bacon contained benzatrate.",
                name + " <b>knew</b> that the goat cheese contained benzatrate, and that the bell pepper contained benzatrate, and that the bacon contained benzatrate.",
                name + " <b>didn't know</b> that the goat cheese contained benzatrate, or that the bell pepper contained benzatrate, or that the bacon contained benzatrate."
            ];
        } else if (story == 1) {
            if (caseNum) {
                return [
                    "The officer <b>didn't know</b> that " + name + " had robbed the liquor store.",
                    "The officer <b>didn't know</b> that " + name + " had robbed the drug store.",
                    "The officer <b>didn't know</b> that " + name + " had robbed the grocery store.",
                    "The officer <b>didn't know</b> that " + name + " had robbed the liquor store or the drug store.",
                    "The officer <b>didn't know</b> that " + name + " had robbed the liquor store or the grocery store.",
                    "The officer <b>didn't know</b> that " + name + " had robbed the drug store or the grocery store.",
                    "The officer <b>didn't know</b> that " + name + " had robbed the liquor store, or the drug store, or the grocery store.",
                    "The officer <b>knew</b> that " + name + " had robbed the liquor store, and the drug store, and the grocery store."
                ];
            }
            return [
                "The officer <b>knew</b> that " + name + " had robbed the liquor store.",
                "The officer <b>knew</b> that " + name + " had robbed the drug store.",
                "The officer <b>knew</b> that " + name + " had robbed the grocery store.",
                "The officer <b>knew</b> that " + name + " had robbed the liquor store and the drug store.",
                "The officer <b>knew</b> that " + name + " had robbed the liquor store and the grocery store.",
                "The officer <b>knew</b> that " + name + " had robbed the drug store and the grocery store.",
                "The officer <b>knew</b> that " + name + " had robbed the liquor store, the drug store, and the grocery store.",
                "The officer <b>didn't know</b> that " + name + " had robbed the liquor store, or the drug store, or the grocery store."
            ];
        } else if (story == 2) {
            if (caseNum) {
                // return [
                //     name + " <b>knew</b> the door was unlocked.",
                //     name + " <b>knew</b> that Mary was expecting him.",
                //     name + " <b>knew</b> that this was Mary's house.",
                //     name + " <b>knew</b> the door was unlocked and that Mary was expecting him.",
                //     name + " <b>knew</b> the door was unlcoked and that this was Mary's house.",
                //     name + " <b>knew</b> that Mary was expecting him and that this was Mary's house.",
                //     name + " <b>knew</b> that the door was unlocked, that Mary was expecting him, and that this was Mary's house.",
                //     name + " <b>didn't know</b> the door was unlocked, that Mary was expecting him, nor that this was Mary's house."
                // ];
                return [
                    name + " <b>didn't know</b> that Lock A was locked.",
                    name + " <b>didn't know</b> that Lock B was locked.",
                    name + " <b>didn't know</b> that Lock C was locked.",
                    name + " <b>didn't know</b> that Lock A was locked, or that Lock B was locked.",
                    name + " <b>didn't know</b> that Lock A was locked, or that Lock C was locked.",
                    name + " <b>didn't know</b> that Lock B was locked, or that Lock C was locked.",
                    name + " <b>didn't know</b> that Lock A was locked, or that Lock B was locked, or that Lock C was locked.",
                    name + " <b>knew</b> that Lock A was locked, and that Lock B was locked, and that Lock C was locked."
                ]
            }
            // return [
            //     name + " <b>didn't know</b> the door was unlocked.",
            //     name + " <b>didn't know</b> that Mary was expecting him.",
            //     name + " <b>didn't know</b> that this was Mary's house.",
            //     name + " <b>didn't know</b> the door was unlocked nor that Mary was expecting him.",
            //     name + " <b>didn't know</b> the door was unlcoked nor that this was Mary's house.",
            //     name + " <b>didn't know</b> that Mary was expecting him nor that this was Mary's house.",
            //     name + " <b>didn't know</b> that the door was unlocked, that Mary was expecting him, nor that this was Mary's house.",
            //     name + " <b>knew</b> the door was unlocked, that Mary was expecting him, and that this was Mary's house."
            // ];
            return [
                name + " <b>knew</b> that Lock A was locked.",
                name + " <b>knew</b> that Lock B was locked.",
                name + " <b>knew</b> that Lock C was locked.",
                name + " <b>knew</b> that Lock A was locked and that Lock B was locked.",
                name + " <b>knew</b> that Lock A was locked and that Lock C was locked.",
                name + " <b>knew</b> that Lock B was locked and that Lock C was locked.",
                name + " <b>knew</b> that Lock A was locked, and that Lock B was locked, and that Lock C was locked.",
                name + " <b>didn't know</b> that Lock A was locked, or that Lock B was locked, or that Lock C was locked."
            ]
        }
        return output;
    };

    /* Returns the proper story for this case using the given name.
     * The instructions show at the top, above the query in the experiment.
     * 
     * Parameters:
     *      story - 0: food allergy
     *              1: police arrest
     *              2: supply room locks
     *      name - randomized name of person in story
     *      case -  0: all x, y, z must be known for best explanation
     *              1: only one of x, y, and z need to be known
     */
    var getStory = function(story, name, caseNum) {
        if (story == 0) {
            return name + " is severely allergic to a common food additive "
                + "called benzatrate. " + name + " was at a party where "
                + "they were serving an appetizer made of goat cheese, bell"
                + " pepper, and bacon. All three ingredients contained "
                + "benzatrate.";
        } else if (story == 1) {
            return "One day, in a small town, " + name + " committed three "
                + "robberies. One was at a liquor store, one was at a drug "
                + "store, and one was at a grocery store. No other crimes were "
                + "reported that day.";
        } else if (story == 2) {
            return "The door to the supply room has three locks: Lock A, "
                + "Lock B, and Lock C. The locks are not always all locked. "
                + "To unlock the locks, employees must get the keys from the "
                + "secretary in another building.";
        } else {
            return "";
        }
    };

    /* Returns the query for this story and case using the given name.
     * The query shows under the instructions in the experiment, stating
     * what action was done.
     * 
     * Parameters:
     *      story - 0: food allergy
     *              1: police arrest
     *              2: entering house
     *      name - randomized name of person in story
     *      case -  0: all x, y, z must be known for best explanation
     *              1: only one of x, y, and z need to be known
     */
    var getQuery = function(story, name, caseNum) {
        if (story == 0) {
            if (caseNum) {
                return name + " ate the appetizer. Rate how satisfying the "
                    + "following explanations are for why " + name + " ate "
                    + "the appetizer.";
            }
            return name + " did not eat the appetizer. Rate how satisfying the "
                + "following explanations are for why " + name
                + " didn't eat the appetizer.";
        } else if (story == 1) {
            if (caseNum) {
                return "The police officer assigned to the cases did not arrest"
                    + " " + name + " that day. Rate how satisfying the "
                    + "following explanations are for why the police officer "
                    + "didn't arrest " + name + ".";
            }
            return "Later that day, a police officer assigned to the cases "
                + "arrested " + name + ". Rate how satisfying the following "
                + "explanations are for why the police officer did arrest "
                + name + ".";
        } else if (story == 2) {
            if (caseNum) {
                // return name + " entered Mary's house without ringing the "
                //     + "doorbell first. Rate how satisfying the following "
                //     + "explanations are for why " + name + " did this.";
                return "An employee, " + name + ", tries opening the door "
                    + "without getting the keys from the secretary. Why didn't "
                    + name + " get the keys first?";
            }
            // return name + " rang the doorbell before entering Mary's house. "
            //     + "Rate how satisfying the following explanations are for why "
            //     + name + " did this.";
            return "An employee, " + name + ", gets the keys before opening the"
                + " door. Why did " + name + " get the keys first?";
        }
        return "";
    };

    var nTrials = 3;
    var trialsLeft = 3;
    var trialNum = 1;
    var lastName = ""; 

    /* array of explanations for worker to rate */
    var allExplanations = getExplanations(storyNum[0], names[0], cases[0]);

    /* randomize order but hold it constant for each run of the experiment */
    var expIDs = _.shuffle(_.range(0, allExplanations.length));

    var next = function() {
        if (trialsLeft <= 0) {
            /* experiment is over */
            finish();
            return;
        }
        /* Reset the page scroll to the top */
        $("html, body").animate({ scrollTop: 0 }, "fast");

        /* empty contents of page from previous trial */
        reset_page();
        
        /* Add the trial number to the top of the page */
        $("<p></p>").appendTo("#trialNumber")
            .text("Case " + trialNum + " of " + nTrials);

        /* The story that appears at the top of each trial */
        var instructions = getStory(storyNum[trialNum - 1], names[0],
            cases[storyNum[trialNum - 1]]);

        /* The query that instructs what action was done, shows under the
         * instructions */
        var query = getQuery(storyNum[trialNum - 1], names[0],
            cases[storyNum[trialNum - 1]]);

        
        allExplanations = getExplanations(storyNum[trialNum - 1], names[0],
            cases[storyNum[trialNum - 1]]);

        /* Add the questions to the page */
        for (var i = 0; i < allExplanations.length; i++) {
            add_mc_question(allExplanations[expIDs[i]], "exp" + expIDs[i],
                7, ['Very bad explanation', '', '', '', '', '',
                    'Very good explanation']);
        }
        add_text_question("Please explain your judgments.","explainanswers");
        add_instructions(instructions, query);

        // fix width based on heading
        check_width();

        // use new name for person X on next trial
        lastName = names[0];
        names.shift();
    };
    
    var finish = function() {
        psiTurk.completeHIT();
    };
    
    // reset_page: Remove everything from the trial screen
    var reset_page = function() {
        $("#trialNumber").empty();
        $("#trial").empty();
        $('#trialImage').empty();
        $('#story').empty();
        $("#query").empty();
        $("#responses").empty();
    };
    
    /* add_instructions: Add the instructions to top of the trial
     *
     * Inputs:
     *      story: the story that sets up the question
     *      query: the question to answer
     */
    var add_instructions = function(story, query) {
        $("<p></p>").appendTo("#story")
            .html(story);
        $("<p></p>").appendTo("#query")
            .html(query);
    };
    
    /* add_mc_question: Add a multiple choice question
     *
     * Inputs:
     *      qText = Text of the question
     *      qID = question ID for data recording purposes
     *      nLevels = number of response levels
     *      labels = ordered array of response level labels (e.g. "not at all", "somewhat", ..., "very much")
     */
    var add_mc_question = function(qText, qID, nLevels, labels) {
  
        // Add the question
        var q = $("<form></form>").appendTo("#responses").
            addClass("question").
            attr("id", qID).
            html(qText);
    
        // Add the response scale
        var newTable = $("<table></table>").appendTo(q).
            addClass("table").
            addClass("rating");
            
        // Add the labels
        var labelRow = "<tr>";
        for (var i = 0; i < nLevels; i++) {
            labelRow += "<td>" + labels[i] + 
                        "<br />" + (i+1).toString() + "</td>";
        }
        labelRow += "</tr>";
        newTable.append(labelRow);
        
        // Add the form
        var inputRow = $("<tr></tr>").appendTo(newTable);
        
        for (var i = 0; i < nLevels; i++) {
            var td = $("<td></td>").appendTo(inputRow);
            var lab = $("<label></label>")
                .appendTo(td);
            $("<input></input>")
                .attr("type","radio")
                .attr("name", qID)
                .attr("id", qID)
                .attr("value", (i+1).toString())
                .appendTo(lab);
        }
    };
    
    /* add_text_question: Add a free response text question
     *
     * Inputs:
     *      qText = Text of the question
     *      qID = question ID for data recording purposes
     */
    var add_text_question = function(qText, qID) {
        var q = $("<div></div>").appendTo("#responses").
            addClass("question");
        
        // Add the question text
        $("<p></p>").appendTo(q).
            text(qText);
        
        // Add the text input field
        $("<textarea></textarea>").appendTo(q).
            addClass("form-control").
            attr("id", qID).
            attr("rows", "4");
    };

    var record_responses = function() {        
        $('input:radio:checked').each(function(i, val) {
            console.log("id=" + this.id + ", expID="
                + expIDs.indexOf(parseInt(this.id.substr(3)))
                + "\nstory = " + allExplanations[parseInt(this.id.substr(3))]);
            psiTurk.recordUnstructuredData(
                'trial=' + trialNum // <1, 2, 3> trial number
                + ' id=' + this.id.substr(3) // index of explanation
                + ' expID=' + expIDs.indexOf(parseInt(this.id.substr(3))) // order in which worker saw it in experiment
                + ' name=' + lastName // name of person in story
                + ' story=' + storyNum[trialNum - 1] // <0, 1, 2> index of story used
                + ' case=' + cases[storyNum[trialNum - 1]], // 0 is case B, 1 is case A
                this.value);
        });
        $('textarea').each(function(i, val) {
            psiTurk.recordUnstructuredData(
                'trial=' + trialNum
                + ' id=' + this.id
                + ' name=' + lastName
                + ' story=' + storyNum[trialNum - 1]
                + ' case=' + cases[storyNum[trialNum - 1]],
                this.value
                    .replace(/(?:\r\n|\r|\n)/g, ' ')
                    .replace(/;/g, '.'));
        });
        
        psiTurk.saveData({
            success: next,
            error: prompt_resubmit
        });
    };
    
    var prompt_resubmit = function() {
        $("#resubmit").click(resubmit);
    };

    var resubmit = function() {
        reprompt = setTimeout(prompt_resubmit, 10000);
        
        psiTurk.saveData({
            success: function() {
                clearInterval(reprompt); 
            }, 
            error: prompt_resubmit
        });
    };
    
    // Load the stage.html snippet into the body of the page
    psiTurk.showPage('stage.html');

    $("#next").click(function() {
        if (trialsLeft > 0) {
            // if there are more trials to be completed

            // Check that all questions have been answered
            var allAnswered = true;
        
            // Check multiple choice questions
            for (var i = 0; i < allExplanations.length; i++) {
                var eID = expIDs[i];
                var answered = $("input:radio[name=exp"+eID+"]:checked").val();
                if (answered == undefined) {
                    $('#exp'+eID).css({"background": "#FFE0E0"});
                    allAnswered = false;
                } else {
                    $('#exp'+eID).css({'background': '#fff'});
                }
            }
        
            // Check free response question
            if ($('#explainanswers').val().length < 1) {
                allAnswered = false;
                $('#explainanswers').css({'background': '#FFE0E0'});
            } else {
                $('#explainanswers').css({'background': '#fff'});
            }
        
            if (allAnswered) {
                record_responses();
                trialNum += 1;
                trialsLeft -= 1;

                // set notComplete alert to invisible when correct
                d3.select('#notComplete')
                    .style('display', 'none');
            } else {
                // did not answer all questions
                d3.select('#notComplete')
                    .style('display', 'block');
            }
        } else {
            // all trials have been completed
            trialNum += 1;
            trialsLeft -= 1;
            record_responses();
        }
    });

    // Start the test
    next();

};

/*******************
 * Run Task
 ******************/
$(window).load( function(){
    psiTurk.doInstructions(
        instructionPages, // a list of pages you want to display in sequence
        function() { currentview = new MyExperiment(); } // what you want to do when you are done with instructions
    );
    
});
