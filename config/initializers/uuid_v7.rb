Rails.application.config.generators do |g|
  g.orm :active_record, primary_key_type: :uuid
end

module UuidV7PrimaryKeyDefault
  def primary_key(name, type = :primary_key, **options)
    if type == :uuid
      options[:default] ||= -> { "uuidv7()" }  # PG 18 builtin
    end
    super
  end
end
ActiveSupport.on_load(:active_record) do
  begin
    if defined?(ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition)
      ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition.prepend(UuidV7PrimaryKeyDefault)
    end
  rescue NameError
    # Adapter not available; skip patching.
  end
end
