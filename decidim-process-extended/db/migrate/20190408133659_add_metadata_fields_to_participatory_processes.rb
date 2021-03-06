class AddMetadataFieldsToParticipatoryProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_participatory_processes, :cost, :decimal
    add_column :decidim_participatory_processes, :has_summary_record, :boolean, default: false
    add_column :decidim_participatory_processes, :facilitators, :string
    add_column :decidim_participatory_processes, :promoting_unit, :string
  end
end
