class NoEndlessSupervisors < ActiveRecord::Migration[8.1]
  def up
    execute <<-END_SQL
      CREATE OR REPLACE FUNCTION no_endless_supervisors() RETURNS trigger AS $end_function$
        DECLARE
          existing_supervisor staff_profiles%ROWTYPE;
        BEGIN
          SELECT * INTO existing_supervisor FROM staff_profiles WHERE id = NEW.supervisor_id AND supervisor_id = NEW.id AND supervisor_id IS NOT NULL;
          IF FOUND THEN
            RAISE EXCEPTION '% cannot be the supervisor of %, since % is already the supervisor of %', NEW.id, existing_supervisor.id, existing_supervisor.id, NEW.id;
          END IF;
          RETURN NEW;
        END;
      $end_function$ LANGUAGE plpgsql;
      CREATE TRIGGER no_endless_supervisors_trigger BEFORE INSERT OR UPDATE ON staff_profiles
        FOR EACH ROW EXECUTE FUNCTION no_endless_supervisors();
    END_SQL
  end
  def down
    execute <<-END_SQL
      DROP TRIGGER no_endless_supervisors_trigger ON staff_profiles;
      DROP FUNCTION no_endless_supervisors;
    END_SQL
  end
end
