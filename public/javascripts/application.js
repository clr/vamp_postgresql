function duplicateInputs(anchor){
  var self = anchor.parentNode;
  var inputs = $('dd#search-inputs');
  var inputs = inputs.clone();
  var inputs = inputs.attr('id', null);
  $(self).after(inputs);
}

function duplicateNest(anchor){
  var self = anchor.parentNode;
  var inputs = $('dd#search-nest');
  var inputs = inputs.clone();
  var inputs = inputs.attr('id', null);
  $(self).after(inputs);
}

function removeLine(anchor){
  var inputs = anchor.parentNode;
  var nest = anchor.parentNode.parentNode;
  var holder = anchor.parentNode.parentNode.parentNode;
  $(inputs).remove();
  if($(nest).children().last()[0].nodeName == "DT"){
    $(holder).remove();
  }
}