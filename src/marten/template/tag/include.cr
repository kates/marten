require "./concerns/*"

module Marten
  module Template
    module Tag
      # The `include` template tag.
      class Include < Base
        include CanExtractAssignments
        include CanSplitSmartly

        @assignments : Hash(String, FilterExpression)
        @isolated : Bool
        @template_name_expression : FilterExpression

        def initialize(parser : Parser, source : String)
          parts = split_smartly(source)

          if parts.last == CONTEXTUAL
            @isolated = false
            parts.pop
          elsif parts.last == ISOLATED
            @isolated = true
            parts.pop
          else
            @isolated = Marten.settings.templates.isolated_inclusions?
          end

          # Ensures that the include tag is not malformed and defines a template name at least.
          if parts.size < 2
            raise Errors::InvalidSyntax.new(
              "Malformed include tag: at least one argument must be provided (template name to include)"
            )
          end

          # Ensures that the third argument is 'with' when assignments are specified.
          if parts.size > 2 && parts[2] != "with"
            raise Errors::InvalidSyntax.new(
              "Malformed include tag: 'with' keyword expected to define variable assignments"
            )
          elsif parts.size == 3
            raise Errors::InvalidSyntax.new(
              "Malformed include tag: the 'with' keyword must be followed by variable assignments"
            )
          end

          @template_name_expression = FilterExpression.new(parts[1])

          @assignments = {} of String => FilterExpression
          extract_assignments(source).each do |name, value|
            if @assignments.has_key?(name)
              raise Errors::InvalidSyntax.new("Malformed include tag: '#{name}' variable defined more than once")
            end

            @assignments[name] = FilterExpression.new(value)
          end
        end

        def render(context : Context) : String
          if !(template_name = @template_name_expression.resolve(context).raw).is_a?(String)
            raise Errors::UnsupportedValue.new(
              "Template name name must resolve to a string, got a #{template_name.class} object"
            )
          end
          template = Marten.templates.get_template(template_name)

          rendered = ""

          outer_context = isolated? ? context.to_empty : context
          outer_context.stack do |include_context|
            @assignments.each do |name, expression|
              include_context[name] = expression.resolve(context)
            end

            rendered = template.render(include_context)
          end

          rendered
        end

        private CONTEXTUAL = "contextual"
        private ISOLATED   = "isolated"

        private getter? isolated
      end
    end
  end
end
