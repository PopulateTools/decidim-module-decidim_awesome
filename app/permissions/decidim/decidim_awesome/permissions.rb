# frozen_string_literal: true

module Decidim
  module DecidimAwesome
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        editor_image_action?

        permission_action
      end

      def editor_image_action?
        return unless permission_action.subject == :editor_image

        config = context.fetch(:awesome_config, {})

        return allow! if config[:allow_images_in_proposals]

        if user.admin
          return allow! if config[:allow_images_in_small_editor]
          return allow! if config[:allow_images_in_full_editor]
        end
      end
    end
  end
end