const TEXT_TO_SPEECH = 'https://stream.watsonplatform.net/text-to-speech/api/v1/synthesize';

function showSection(id) {
  Array.prototype.forEach.call(
    document.querySelectorAll("section"),
    function(element) {
      if (element.id == id) {
        element.classList.remove("hidden");
      } else {
        element.classList.add("hidden");
      }
    }
  );
}

function showLoader() {
  showSection("loader");
}

function loadSeeds() {
  showLoader();
  axios.get('/sample_words').then(function(response) {
    // clear seeds
    var seeds = document.querySelector('#seeds');
    while (seeds.firstChild) {
      seeds.removeChild(seeds.firstChild);
    }

    // append new seeds
    response.data.words.forEach(function(seed, i) {
      seedBtn = document.createElement("button");
      seedBtn.textContent = seed;
      seedBtn.style.animationDelay = "" + (i*0.05) + "s";
      seedBtn.addEventListener("click", function() {
        generate(seed);
      });
      seeds.appendChild(seedBtn);
    });

    showSection('intro');
  });
}

function generate(seed) {
  showLoader();
  axios.post('/generate', {seed: seed}).then(function(response) {
    // clear verses
    var verses = document.querySelector('#verses');
    while (verses.firstChild) {
      verses.removeChild(verses.firstChild);
    }

    response.data.lines.forEach(function(line, i) {
      var lineDiv = document.createElement("div");
      lineDiv.style.animationDelay = "" + (i*0.2) + "s";
      lineDiv.textContent = line;
      verses.appendChild(lineDiv);
    });

    showSection("rap");
  });
}

function textToSpeech() {
  axios.post('/gen_audio', { text: text });
}

document.querySelector("#more").addEventListener("click", loadSeeds);
document.querySelector("#another").addEventListener("click", loadSeeds);
loadSeeds();
