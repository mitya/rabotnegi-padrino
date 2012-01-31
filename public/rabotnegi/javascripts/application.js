/* DO NOT MODIFY. This file was compiled Sat, 28 Jan 2012 10:36:45 GMT from
 * /Volumes/Code/abox/app/javascripts/application.coffee
 */

(function() {

  $("body.public").loaded(function() {
    if ($("#tabs").attr("data-selected") !== '#') {
      return $("#tabs").attr("data-selected").query().addClass("selected");
    }
  });

  $("body.admin").loaded(function() {
    return $(".menu .menu-trigger").click(function() {
      return $(this).closest(".menu").toggleClass("active");
    });
  });

  $("body#admin-vacancies").loaded(function() {
    var edited_rows;
    edited_rows = {};
    $("#vacancies .pagination a").live('click', function() {
      $("#vacancies").load(this.href);
      return false;
    });
    $("#vacancies tr td.actions .edit").live('click', function() {
      var id, row;
      row = $(this).closest('tr');
      id = row.record_id();
      edited_rows[id] = row;
      return $.get("/admin/vacancies/" + id + "/edit", function(result) {
        return row.replaceWith(result);
      });
    });
    $("#vacancies tr td.actions .cancel").live('click', function() {
      var id, row;
      row = $(this).closest('tr');
      id = row.record_id();
      row.replaceWith(edited_rows[id]);
      return delete edited_rows[id];
    });
    return $("#vacancies tr td.actions .save").live('click', function() {
      var id, row;
      row = $(this).closest('tr');
      id = row.record_id();
      $.ajax({
        url: "/admin/vacancies/" + id,
        type: 'POST',
        data: row.find(':input').serialize() + "&_method=PUT",
        success: function() {}
      });
      return delete edited_rows[id];
    });
  });

  $("body#edit-resume").loaded(function() {
    $("#edit-resume").find("#resume_about_me, #resume_job_reqs, #resume_contact_info").tooltip();
    return $("#edit-resume").find("#resume_fname, #resume_lname").requiredField();
  });

  $("body.public").loaded(function() {
    $(".vacancies-list").delegate("tr.entry-header a", "click", function() {
      return $(this).closest('tr').click;
    });
    $(".vacancies-list").delegate("tr.entry-header .star-disabled", "click", function() {
      var tr,
        _this = this;
      tr = q(this).closest("tr");
      q.post("/worker/vacancies", {
        id: tr.record_id()
      }, function() {
        return q(_this).removeClass("star-disabled").addClass("star-enabled");
      });
      return false;
    });
    $(".vacancies-list").delegate("tr.entry-header .star-enabled", "click", function() {
      var tr,
        _this = this;
      tr = q(this).closest("tr");
      q.post("/worker/vacancies/" + (tr.record_id()), {
        _method: 'delete'
      }, function() {
        return q(_this).removeClass("star-enabled").addClass("star-disabled");
      });
      return false;
    });
    $(".vacancies-list").delegate("tr.entry-header", "click", function() {
      var link, row;
      row = $(this);
      link = row.find('a');
      if (row.next().is(".entry-details")) {
        row.toggleClass("x-open");
        row.next().find(".entry-box").toggle();
      } else {
        row.addClass("x-loading");
        $.get(link.attr('href'), function(html) {
          var details;
          details = $(html).insertAfter(row);
          row.removeClass("x-loading").addClass('x-loaded');
          details.addClass('x-loaded');
          if (row.hasClass('alt')) details.addClass('alt');
          row.find(".spinner").remove();
          row.addClass("x-open");
          return details.find(".entry-box").fadeIn();
        });
      }
      return false;
    });
    return $("#vacancies-filter").submit(function() {
      var form, url;
      form = this;
      url = "/vacancies/" + form.city.value;
      if (form.industry.value.present()) url += '/' + form.industry.value;
      if (form.q.value.present()) {
        url += '?q=' + encodeURIComponent(form.q.value).replace(/(%20)+/g, '+');
      }
      window.location = url;
      return false;
    });
  });

}).call(this);
