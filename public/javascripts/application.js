function duplicateInputs(anchor){
  var target = anchor.parentNode.parentNode;
  var inputs = $('dd#search-inputs');
  var inputs = inputs.clone();
  var inputs = inputs.attr('id', null);
  inputs.appendTo(target);
}

function duplicateNest(anchor){
  var target = anchor.parentNode.parentNode;
  var inputs = $('dd#search-nest');
  var inputs = inputs.clone();
  var inputs = inputs.attr('id', null);
  inputs.appendTo(target);
}

function removeLine(anchor){
  var inputs = anchor.parentNode;
  inputs.parentNode.removeChild(inputs);
}
