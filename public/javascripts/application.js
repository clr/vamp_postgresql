function duplicateInputs(){
  // Select the DOM element that holds all of the inputs.
  var inputs = $('dl#original-inputs');
  // Clone those nodes.
  var inputs = inputs.clone();
  // Set the id to null, because we don't want to copy that.
  var inputs = inputs.attr('id', null);
  // Append a copy of the inputs to the form.
  inputs.appendTo('form');
}

function removeLine(anchor){
  // Select the parent's parent DOM element of the <a> that was clicked.
  var inputs = anchor.parentNode.parentNode;
  // Drop it like a hot potato from the DOM tree.
  inputs.parentNode.removeChild(inputs);
}
