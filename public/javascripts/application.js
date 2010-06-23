function duplicateInputs(anchor){
  var target = anchor.parentNode.parentNode;
  var inputs = $('dd#search-inputs');
  var inputs = inputs.clone();
  var inputs = inputs.attr('id', null);
  inputs.appendTo(target);
}

function duplicateNest(){
  var inputs = $('dl#search-nest');
  var inputs = inputs.clone();
  var inputs = inputs.attr('id', null);
  inputs.appendTo('form');
}

function removeLine(anchor){
  // Select the parent's parent DOM element of the <a> that was clicked.
  var inputs = anchor.parentNode;
  // Drop it like a hot potato from the DOM tree.
  inputs.parentNode.removeChild(inputs);
}
