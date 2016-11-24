module Crecto
  module Changeset
    class Changeset
      property action : Symbol?
      property errors = [] of Hash(Symbol, String)
      property changes = [] of Hash(Symbol, Bool | Float64 | Int32 | Int64 | String | Nil)
      property source : Hash(Symbol, Bool | Float64 | Int32 | Int64 | String | Nil)?

      private property valid = true
      private property class_key : String?
      private property instance_hash : Hash(Symbol, Bool | Float64 | Int32 | Int64 | String | Nil)

      def initialize(instance)
        @class_key = instance.class.to_s
        @instance_hash = instance.to_query_hash
        @source = instance.initial_values

        check_required!
        check_formats!
        check_inclusions!
        check_exclusions!
        check_lengths!
        diff_from_initial_values!
      end

      def valid?
        @valid
      end

      private def check_required!
        return unless REQUIRED_FIELDS.has_key?(@class_key)
        REQUIRED_FIELDS[@class_key].each do |field|
          add_error(field.to_s, "is required") unless @instance_hash.has_key?(field)
        end
      end

      private def check_formats!
        return unless REQUIRED_FORMATS.has_key?(@class_key)
        REQUIRED_FORMATS[@class_key].each do |format|
          next unless @instance_hash.has_key?(format[:field])
          raise Crecto::InvalidType.new("Format validator can only validate strings") unless @instance_hash.fetch(format[:field]).is_a?(String)
          val = @instance_hash.fetch(format[:field]).as(String)
          add_error(format[:field].to_s, "is invalid") if format[:pattern].match(val).nil?
        end
      end

      private def check_inclusions!
        return unless REQUIRED_INCLUSIONS.has_key?(@class_key)
        REQUIRED_INCLUSIONS[@class_key].each do |inclusion|
          next unless @instance_hash.has_key?(inclusion[:field])
          val = @instance_hash.fetch(inclusion[:field])
          add_error(inclusion[:field].to_s, "is invalid") unless inclusion[:in].to_a.includes?(val)
        end
      end

      private def check_exclusions!
        return unless REQUIRED_EXCLUSIONS.has_key?(@class_key)
        REQUIRED_EXCLUSIONS[@class_key].each do |exclusion|
          next unless @instance_hash.has_key?(exclusion[:field])
          val = @instance_hash.fetch(exclusion[:field])
          add_error(exclusion[:field].to_s, "is invalid") if exclusion[:in].to_a.includes?(val)
        end
      end

      private def check_lengths!
        return unless REQUIRED_LENGTHS.has_key?(@class_key)
        REQUIRED_LENGTHS[@class_key].each do |length|
          next unless @instance_hash.has_key?(length[:field])
          val = @instance_hash.fetch(length[:field]).as(String)
          add_error(length[:field].to_s, "is invalid") if !length[:is].nil? && val.size != length[:is].as(Int32)
          add_error(length[:field].to_s, "is invalid") if !length[:min].nil? && val.size < length[:min].as(Int32)
          add_error(length[:field].to_s, "is invalid") if !length[:max].nil? && val.size > length[:max].as(Int32)
        end
      end

      private def diff_from_initial_values!
        @initial_values = {} of Symbol => Int32 | Int64 | String | Float64 | Bool | Nil if @initial_values.nil?
        @changes.clear
        @instance_hash.each do |field, value|
          @changes.push({field => value}) if @initial_values.as(Hash).fetch(field, nil) != value
        end
      end

      private def add_error(key, val)
        errors.push({field: key, message: val}.to_h)
        @valid = false
      end

    end
  end
end