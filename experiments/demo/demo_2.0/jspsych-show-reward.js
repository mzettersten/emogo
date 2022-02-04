/**
 * jsPsych plugin bandit task - reward screen
 *
 * Martin Zettersten
 *
 * documentation: docs.jspsych.org
 *
 */

jsPsych.plugins['show-reward'] = (function() {

  var plugin = {};

  jsPsych.pluginAPI.registerPreload('show-reward', 'stimulus', 'image');

  plugin.info = {
    name: 'show-reward',
    description: '',
    parameters: {
      stimulus: {
        type: jsPsych.plugins.parameterType.IMAGE,
        pretty_name: 'Stimuli',
        default: undefined,
        array: false,
        description: 'A stimulus is a path to an image file.'
      },
      reward_image: {
        type: jsPsych.plugins.parameterType.IMAGE,
        pretty_name: 'Reward Image',
        default: undefined,
        array: false,
        description: 'A stimulus is a path to an image file.'
      },
      canvas_size: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Canvas size',
        array: true,
        default: [1000,800],
        description: 'Array specifying the width and height of the area that the animation will display in.'
      },
      image_size: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Image size',
        array: true,
        default: [300,300],
        description: 'Array specifying the width and height of the images to show.'
      },
	  rewards: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'rewards',
        array: true,
        default: [8,16,32,64],
        description: 'Array specifying the rewards for each bandit choice'
      },
      cur_reward: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Current Reward',
        array: false,
        default: 8,
        description: 'current reward being shown to participant'
      },
	  cur_score: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'cur_score',
        array: false,
        default: 1,
        description: 'current score of participant'
      },
      trial_duration: {
        type: jsPsych.plugins.parameterType.INT,
        pretty_name: 'Trial duration',
        default: 2000,
        description: 'How long to show trial before it ends.'
      },
    }
  }

  plugin.trial = function(display_element, trial) {
    
    // variable to keep track of timing info and responses
    var start_time = 0;
  	var end_time = "NA";
	var reward = "NA";
    
  var trial_data={};

    // start timer for this trial
    start_time = performance.now();
	
    display_element.innerHTML = "<svg id='jspsych-test-canvas' width=" + trial.canvas_size[0] + " height=" + trial.canvas_size[1] + "></svg>";

    var paper = Snap("#jspsych-test-canvas");
	
  var rect = paper.rect(25, 200, 350,350,10);
  rect.attr({
	  fill: "#ffffff",
	  stroke: "#000",
	  strokeWidth: 5
  });
  
  var imageLocations = {
	  centerLeft: [50, 225],
	  centerRight: [450, 225]
	  
  };
  
  var scoreBoxLength = 600;
  var scoreBox = paper.rect(900, 50,50,scoreBoxLength);
  scoreBox.attr({
	  fill:'#926239',
	  stroke: "#000",
	  strokeWidth: 5,
  });
  
  var score_index = paper.rect(905, scoreBoxLength+45-trial.cur_score,40,trial.cur_score);
  score_index.attr({
  	  fill:'#368f8b',
  	  stroke: "#000",
  	  strokeWidth: 0,
  });

  
  
  var image = paper.image(trial.stimulus, imageLocations["centerLeft"][0], imageLocations["centerLeft"][1], trial.image_size[0],trial.image_size[1]);
  
  var reward_image = paper.image(trial.reward_image, imageLocations["centerRight"][0], imageLocations["centerRight"][1], trial.image_size[0],trial.image_size[1]);


    function endTrial() {
    	end_time = performance.now();
    	display_element.innerHTML = '';
    	var trial_data = {
    		//"label": trial.label,
    		start_time: start_time,
    		end_time: end_time,
    		stimulus: trial.stimulus,
    		reward: trial.reward,
    		reward_image: trial.reward_image,
    		score_after_trial: trial.cur_score
    	};
    	jsPsych.finishTrial(trial_data);
    }

  jsPsych.pluginAPI.setTimeout(function() {
        endTrial();
      }, trial.trial_duration);

  };

  return plugin;
})();
