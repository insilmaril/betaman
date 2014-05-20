# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $('#users').dataTable
    sPaginationType: "full_numbers"
    bJQueryUI: true
    bProcessing: true
    bServerSide: true
    "iDisplayLength": 20
    "aLengthMenu": [[10, 20, 50, 100, -1], [10,20,50,100, "All"]]
    sAjaxSource: $('#users').data('source')

jQuery -> 
  $('#user_company_name').autocomplete
    source: $('#user_company_name').data('autocomplete-source')

jQuery -> 
  $('#user_requester').autocomplete
    source: $('#user_requester').data('autocomplete-source')
