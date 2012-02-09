$("body.public").loaded ->
  $("#tabs").attr("data-selected").query().addClass("selected") unless $("#tabs").attr("data-selected") == '#'

$("body.admin").loaded ->
  $(".menu .menu-trigger").click ->
    $(this).closest(".menu").toggleClass("active")

$("body#admin-vacancies").loaded ->
  edited_rows = {}

  $("#vacancies .pagination a").live 'click', ->
    $("#vacancies").load(@href)
    false
  
  $("#vacancies tr td.actions .edit").live 'click', ->
    row = $(this).closest('tr')
    id = row.record_id()
    edited_rows[id] = row
    $.get "/admin/vacancies/#{id}/edit", (result) ->
      row.replaceWith(result)
  
  $("#vacancies tr td.actions .cancel").live 'click', ->
    row = $(this).closest('tr')
    id = row.record_id()
    row.replaceWith(edited_rows[id])
    delete edited_rows[id]      
  
  $("#vacancies tr td.actions .save").live 'click', ->
    row = $(this).closest('tr')
    id = row.record_id()
    $.ajax
      url: "/admin/vacancies/#{id}"
      type: 'POST'
      data: row.find(':input').serialize() + "&_method=PUT"
      success: ->
    delete edited_rows[id]

$("body#edit-resume").loaded ->
  $("#edit-resume").find("#resume_about_me, #resume_job_reqs, #resume_contact_info").tooltip()
  $("#edit-resume").find("#resume_fname, #resume_lname").requiredField()

$("body.public").loaded ->
  $(".vacancies-list").delegate "tr.entry-header a", "click", -> $(this).closest('tr').click

  $(".vacancies-list").delegate "tr.entry-header .star-disabled", "click", ->
    tr = q(this).closest("tr")
    q.post "/vacancies/remember/#{tr.record_id()}", => 
      q(this).removeClass("star-disabled").addClass("star-enabled")
    false
    
  $(".vacancies-list").delegate "tr.entry-header .star-enabled", "click", ->
    tr = q(this).closest("tr")
    q.post "/vacancies/forget/#{tr.record_id()}", => 
      q(this).removeClass("star-enabled").addClass("star-disabled")    
    false
  
  $(".vacancies-list").delegate "tr.entry-header", "click", ->
    row = $(this)
    link = row.find('a')

    if row.next().is(".entry-details")
      row.toggleClass("x-open")
      row.next().find(".entry-box").toggle()
    else
      row.addClass("x-loading")
      $.get link.attr('href'), (html) ->
        details = $(html).insertAfter(row)
        row.removeClass("x-loading").addClass('x-loaded')
        details.addClass('x-loaded')
        details.addClass('alt') if row.hasClass('alt')
        row.find(".spinner").remove()
        row.addClass("x-open")
        details.find(".entry-box").fadeIn()
        
    false

  $("#vacancies-filter").submit ->
    form = this
    url = "/vacancies/#{form.city.value}"
    url += '/' + form.industry.value if form.industry.value.present()
    url += '?q=' + encodeURIComponent(form.q.value).replace(/(%20)+/g, '+') if form.q.value.present()
    window.location = url
    false
