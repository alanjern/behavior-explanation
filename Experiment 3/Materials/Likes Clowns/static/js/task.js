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

// Experimental condition variables
var DIAGRAM = ['/static/images/stage-1.png', 'static/images/stage-2.png', 'static/images/stage-3.png', 'static/images/stage-4.png', 'static/images/stage-5.png'];


/********************
* Experiment      *
********************/

var MyExperiment = function() {

    var error_message = "<h1>Oops!</h1><p>Something went wrong submitting your HIT. This might happen if you lose your internet connection. Press the button to resubmit.</p><button id='resubmit'>Resubmit</button>";
    
    var names = _.shuffle(['Jacob', 'David', 'Alex', 'Matt']);

    // all possible positions for a performer on stage
    var explanations = ['<strong>clown</strong> would be on <strong>Stage A</strong>', '<strong>magician</strong> would be on <strong>Stage A</strong>', '<strong>acrobat</strong> would be on <strong>Stage A</strong>',
                        '<strong>clown</strong> would be on <strong>Stage B</strong>', '<strong>magician</strong> would be on <strong>Stage B</strong>', '<strong>acrobat</strong> would be on <strong>Stage B</strong>',
                        '<strong>clown</strong> would be on <strong>Stage C</strong>', '<strong>magician</strong> would be on <strong>Stage C</strong>', '<strong>acrobat</strong> would be on <strong>Stage C</strong>'];

    /*
    *  Generates an array of all desired explanations to display to subject.
    *  Only difference in between trials is the change in name.
    */
    var getExplanations = function() {
        output = []
        for (var i = 0; i < explanations.length; i+=3) {
            output.push(names[0] + ' believed that the ' + explanations[i]);
        }
        for (var i = 1; i < explanations.length; i+=3) {
            output.push(names[0] + ' believed that the ' + explanations[i]);
        }
        for (var i = 0; i < 3; i++) {
            for (var j = 3; j < 6; j++) {
                if (j % 3 !== i) {
                    for (var k = 6; k < explanations.length; k++) {
                        if (k % 3 !== j % 3 && k % 3 !== i) {
                            output.push(names[0] + ' believed that the ' + explanations[i] + ', the ' + explanations[j] + ', and the ' + explanations[k]);
                        }
                    }
                }
            }
        }
        output.push(names[0] + ' didn\'t know where any of the performers would be');
        return output;
    };

    /*
    *  Generates an array of all desired explanations to display to subject.
    *  Only difference in between trials is the change in name.
    *   
    *  This is the flipped case, where the explanations are flipped because
    *  the situation is symmetric as if the person was sitting on the left.
    */
    var getExplanationsFlipped = function() {
        output = []
        for (var i = 0; i < explanations.length; i+=3) {
            output.push(names[0] + ' believed that the ' + explanations[6 - i]);
        }
        for (var i = 0; i < explanations.length; i+=3) {
            output.push(names[0] + ' believed that the ' + explanations[7 - i]);
        }
        for (var i = 0; i < 3; i++) {
            for (var j = 3; j < 6; j++) {
                if (j % 3 !== i) {
                    for (var k = 6; k < explanations.length; k++) {
                        if (k % 3 !== j % 3 && k % 3 !== i) {
                            output.push(names[0] + ' believed that the ' + explanations[k-6] + ', the ' + explanations[j] + ', and the ' + explanations[i+6]);
                        }
                    }
                }
            }
        }
        output.push(names[0] + ' didn\'t know where any of the performers would be');
        return output;
    };

    var allExplanations = getExplanations();

    // randomize the order but hold it constant for each run of the experiment
    var expIDs = _.shuffle(_.range(0, allExplanations.length));

    // different cases for different experiments (this one is 'likes')
    var cases = ["likes", "dislikes"];
    
    // what is shown under the image in each trial
    var query = "";

    var nTrials = 3;
    var trialsLeft = 3;
    var trialNum = 1;
    var section = 0;
    var lastName = "";

    // sections which have not yet been chosen in a trial
    var availableSections = [0, 1, 2, 3, 4];

    // activates next trial in experiment
    var next = function() {
        if (trialsLeft < 0) {
            // experiment is over
            finish();
        } else {
            // Reset the page
            $("html, body").animate({ scrollTop: 0 }, "fast");

            // empty content of page
            reset_page();
            
            // Add the trial number
            $("<p></p>").appendTo("#trialNumber")
                .text("Case "+trialNum+" of "+(nTrials+1));

            // Add the instructions (moved to instruction page for now)
            var instructions = "";

            // 0: left, 1: right
            section = Math.floor(Math.random() * 2);

            if (section == 0) {
                allExplanations = getExplanations();
            } else {
                allExplanations = getExplanationsFlipped();
            }

            // Add the questions
            for (var i = 0; i < allExplanations.length; i++) {
                add_mc_question(allExplanations[expIDs[i]], "exp"+expIDs[i], 7, ['Very bad explanation','','','','','','Very good explanation']);
            }
            add_text_question("Please explain your judgments.","explainanswers");

            // update query with current name
            query = names[0]+" chose the section marked above. Rate how satisfying the following explanations are for why "+names[0]+" chose to sit there.";
            
            if (trialsLeft == 0) {

                // update query to be attention test
                query = "This case is only meant to check if you are reading the instructions carefully. Please ignore the information and leave all of the questions blank.";

                // random index of available sections remaining
                section = availableSections[Math.floor(Math.random() * availableSections.length)];
                add_instructions(instructions, DIAGRAM[section], query);
            } else {

                // update query with current name
                query = "<strong>"+names[0]+" "+cases[0]+" clowns and is indifferent toward acrobats and magicians.</strong> "+names[0]+" chose the section marked above. Rate how satisfying the following explanations are for why "+names[0]+" chose to sit there.";

                // index of diagram to use
                section = section == 0 ? section + trialNum - 1 : DIAGRAM.length - trialNum;
    
                // remove chosen section from availableSections
                availableSections.splice(availableSections.indexOf(section), 1);
                add_instructions(instructions, DIAGRAM[section], query);
            }

            // fix width based on heading
            check_width();

            // use new name for person X on next trial
            lastName = names[0]
            names.shift();

            // ONLY FOR TESTING, selects all radio buttons with value 1
            // document.getElementById("checkAll").onclick = function () {
            //     for (var i = 0; i < allExplanations.length; i++) {
            //         $("input:radio[name=exp"+i+"][value=1]").prop("checked", true);
            //     }
            // };
        }
    };

    
    var finish = function() {
        psiTurk.completeHIT();
    };
    
    // reset_page: Remove everything from the trial screen
    var reset_page = function() {
        $("#trialNumber").empty();
        $("#trial").empty();
        $('#trialImage').empty();
        $("#query").empty();
        $("#responses").empty();
    };
    
    // add_instructions: Add the instructions to top of the trial
    //
    // Inputs:
    // iText: instruction text
    // img: the seating diagram
    // query: the question to answer
    var add_instructions = function(iText, img, query) {
        $("<p></p>").appendTo("#trial")
            .text(iText);
        $("<img>").appendTo("#trialImage")
            .attr('src', img);
        $("<p></p>").appendTo("#query")
            .html(query);
    };
    
    // add_mc_question: Add a multiple choice question
    //
    // Inputs:
    // qText = Text of the question
    // qID = question ID for data recording purposes
    // nLevels = number of response levels
    // labels = ordered array of response level labels (e.g. "not at all", "somewhat", ..., "very much")
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
        inputRow = $("<tr></tr>").appendTo(newTable);
        
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
    
    // add_text_question: Add a free response text question
    //
    // Inputs:
    // qText = Text of the question
    // qID = question ID for data recording purposes
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
        $('input:radio:checked').each( function(i, val) {
            psiTurk.recordUnstructuredData('trial '+(trialNum - 1)+': '+this.id+' '+expIDs.indexOf(parseInt(this.id.substr(3)))+' '+section+' '+lastName, this.value);
        });
        $('textarea').each( function(i, val) {
            psiTurk.recordUnstructuredData('trial '+(trialNum - 1)+': '+this.id, this.value);
        });
        
        psiTurk.saveData({
            success: next,
            error: prompt_resubmit
        });
    };
    
    var prompt_resubmit = function() {
        replaceBody(error_message);
        $("#resubmit").click(resubmit);
    };

    var resubmit = function() {
        replaceBody("<h1>Trying to resubmit...</h1>");
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

    $("#next").click(function () {
    
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
                trialNum += 1;
                trialsLeft -= 1;
                record_responses();

                // set notComplete alert to invisible when correct
                d3.select('#notComplete')
                    .style('display', 'none');
            } else {
                // did not answer all questions
                d3.select('#notComplete')
                    .style('display', 'block');
            }
        }
        else {
            // all trials have been completed
            trialNum += 1;
            trialsLeft -= 1;
            record_responses();
        }
        
    });

    $('.tooltip').tooltip({
        title: "Four unrelated people, Jacob, David, Alex, and Matt, were all given a coupon to redeem for a free ticket to a show. The show has three stages with different performers. A clown performs on one stage, an acrobat performs on one stage, and a magician performs on one stage. Each person went online and chose one section (of five) to sit in. All stages are at least partially visible from every section, but closer stages are easier to see.",
        placement: "bottom"
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
