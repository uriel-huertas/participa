# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A controller that holds the logic to show ParticipatoryProcesses in a
    # public layout.
    class ParticipatoryProcessesController < Decidim::ApplicationController
      layout "layouts/decidim/participatory_process", only: [:show]

      before_action -> { extend NeedsParticipatoryProcess }, only: [:show]

      helper Decidim::AttachmentsHelper
      helper Decidim::IconHelper
      helper Decidim::WidgetUrlsHelper

      helper ParticipatoryProcessHelper

      helper_method :collection, :promoted_participatory_processes, :participatory_processes, :stats, :filter, :categories, :has_debats, :is_subcategory

      def index
        authorize! :read, ParticipatoryProcess
        authorize! :read, ParticipatoryProcessGroup
      end

      def show
        authorize! :read, current_participatory_process
      end

      private

      def collection
        @collection ||= (participatory_processes.to_a).flatten
      end

      def filtered_participatory_processes(filter = default_filter)
        OrganizationPrioritizedParticipatoryProcesses.new(current_organization, filter)
      end

      def participatory_processes
        @participatory_processes ||= filtered_participatory_processes(filter)
      end

      def promoted_participatory_processes
        @promoted_processes ||= filtered_participatory_processes | PromotedParticipatoryProcesses.new
      end

      def participatory_process_groups
        @process_groups ||= OrganizationPrioritizedParticipatoryProcessGroups.new(current_organization, filter)
      end

      def stats
        @stats ||= ParticipatoryProcessStatsPresenter.new(participatory_process: current_participatory_process)
      end

      def filter
        @filter = params[:filter] || default_filter
      end

      def default_filter
        "active"
      end

      def categories
        @categories ||= Decidim::Category.where(decidim_participatory_space_id: current_participatory_process.id, decidim_participatory_space_type: "Decidim::ParticipatoryProcess")
      end

      def has_debats(process_id)
        @has_debats ||= Decidim::Feature.where(participatory_space_id: process_id, manifest_name: "proposals").where.not(published_at: nil)
      end

      def is_subcategory(category_id)
        @is_subcategory = Decidim::Category.all.where(id: category_id).where.not(parent_id: nil).exists?
      end

    end
  end
end