


output "render" {
  
    value = {for template_key, template in data.template_file.template: template_key => template.rendered}

}