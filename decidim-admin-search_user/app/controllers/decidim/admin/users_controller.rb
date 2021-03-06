# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing all admins at the admin panel.
    #
    class UsersController < Decidim::Admin::ApplicationController
      def index
        enforce_permission_to :read, :admin_user

        if params.has_key?(:user_search)
            @users = search_collection.page(params[:page]).per(15)
            puts @users
        else
            @users = collection.page(params[:page]).per(15)
        end
      end

      def new
        enforce_permission_to :create, :admin_user
        @form = form(InviteUserForm).instance
      end

      def create
        enforce_permission_to :create, :admin_user

        default_params = {
          organization: current_organization,
          invitation_instructions: "invite_admin",
          invited_by: current_user
        }

        @form = form(InviteUserForm).from_params(params.merge(default_params))

        InviteAdmin.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("users.create.success", scope: "decidim.admin")
            redirect_to users_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("users.create.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def resend_invitation
        enforce_permission_to :invite, :admin_user, user: user

        InviteUserAgain.call(user, "invite_admin") do
          on(:ok) do
            flash[:notice] = I18n.t("users.resend_invitation.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash[:alert] = I18n.t("users.resend_invitation.error", scope: "decidim.admin")
          end
        end

        redirect_to users_path
      end

      def destroy
        enforce_permission_to :destroy, :admin_user, user: user

        RemoveAdmin.call(user, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("users.destroy.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash[:alert] = I18n.t("users.destroy.error", scope: "decidim.admin")
          end
        end

        redirect_to users_path
      end

      private

      def user
        @user ||= collection.find(params[:id])
      end

      def collection
        @collection ||= current_organization.admins.or(current_organization.users_with_any_role)
      end

      def search_collection
        @search_collection ||= collection.where("LOWER(name) like LOWER(?) or LOWER(email) like LOWER(?)", '%' + params[:user_search] + '%', '%' + params[:user_search] + '%')
      end
    end
  end
end
