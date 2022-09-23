CREATE TABLE [dbo].[carrierinsurance]
(
[cai_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[cai_insurance_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cai_effective_dt] [datetime] NULL,
[cai_expiration_dt] [datetime] NULL,
[cai_liability_limit] [money] NULL,
[cai_comment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cai_cmpissued] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cai_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cai_updatedt] [datetime] NULL,
[cai_policynumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cai_imageURL] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cai_Source] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[caix_id] [int] NULL,
[ciax_determination] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cai_AgentName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cai_AgentPhone] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[cai_AgentFax] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_carrierinsurance] ON [dbo].[carrierinsurance]
FOR DELETE
AS
DECLARE @min_id			INTEGER,
        @CMSInsuranceExpiration CHAR(1),
	@tmwuser 		VARCHAR(255),
	@car_id			VARCHAR(8),
	@cai_insurance_type	VARCHAR(6)

EXEC gettmwuser @tmwuser OUTPUT

SELECT @cmsinsuranceexpiration = UPPER(ISNULL(gi_string1, 'N'))
  FROM generalinfo
 WHERE gi_name = 'CMSInsuranceExpirations'


SET @min_id = 0
SELECT @min_id = MIN(cai_id)
  FROM deleted
 WHERE cai_id > @min_id

WHILE @min_id > 0 
BEGIN

   IF @min_id IS NULL
      BREAK

   IF @cmsinsuranceexpiration = 'Y'
   BEGIN
      IF EXISTS (SELECT *
                   FROM expiration
                  WHERE cai_id = @min_id)
      BEGIN
         DELETE FROM expiration
          WHERE cai_id = @min_id
      END
   END

   SELECT @min_id = MIN(cai_id)
     FROM inserted
    WHERE cai_id > @min_id

END

IF (SELECT ISNULL(UPPER(LEFT(gi_string1, 1)), 'N')
      FROM generalinfo
     WHERE gi_name = 'CarrierFileAudit') = 'Y'
BEGIN
	INSERT INTO carrierinsuranceaudit (car_id, cai_insurance_type, cia_action, cia_update_dt, cia_update_by)
	SELECT 
		car_id, 
		cai_insurance_type, 
		'DELETE', 
		GETDATE(), 
		@tmwuser
	FROM deleted
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_carrierinsurance] ON [dbo].[carrierinsurance]
FOR INSERT,UPDATE
AS
DECLARE @min_id			INTEGER,
        @tmwuser 		VARCHAR(255),
	@CMSInsuranceExpiration CHAR(1),
        @car_id			VARCHAR(8),
        @cai_insurance_type	VARCHAR(6),
        @cai_expiration_dt	DATETIME,
	@deletedcount		INTEGER,
	@oldvalue		VARCHAR(100),
	@newvalue		VARCHAR(100),
	@updatedate		DATETIME

SELECT @cmsinsuranceexpiration = UPPER(ISNULL(gi_string1, 'N'))
  FROM generalinfo
 WHERE gi_name = 'CMSInsuranceExpirations'

exec gettmwuser @tmwuser output

SET @min_id = 0
SELECT @min_id = MIN(cai_id)
  FROM inserted
 WHERE cai_id > @min_id

WHILE @min_id > 0 
BEGIN

   IF @min_id IS NULL
      BREAK

   UPDATE carrierinsurance
      SET cai_updatedby = @tmwuser,
          cai_updatedt = GETDATE()
    WHERE cai_id = @min_id

   IF @cmsinsuranceexpiration = 'Y'
   BEGIN
      IF EXISTS (SELECT *
                   FROM expiration
                  WHERE cai_id = @min_id)
         BEGIN
            SELECT @cai_insurance_type = i.cai_insurance_type,
                   @cai_expiration_dt = i.cai_expiration_dt
              FROM inserted i
             WHERE cai_id = @min_id
            UPDATE expiration
               SET exp_code = @cai_insurance_type,
                   exp_lastdate = @cai_expiration_dt,
                   exp_expirationdate = @cai_expiration_dt,
                   exp_updateby = @tmwuser,
                   exp_updateon = GETDATE()
             WHERE cai_id = @min_id
         END
      ELSE
         BEGIN
            SELECT @car_id = i.car_id,
                   @cai_insurance_type = i.cai_insurance_type,
                   @cai_expiration_dt = i.cai_expiration_dt
              FROM inserted i
             WHERE cai_id = @min_id
            INSERT INTO expiration (exp_idtype, exp_id, exp_code, exp_lastdate, exp_expirationdate,
                                    exp_routeto, exp_completed, exp_priority, exp_compldate,
                                    exp_city, exp_updateby, exp_creatdate, cai_id)
                            VALUES ('CAR', @car_id, @cai_insurance_type, @cai_expiration_dt,
                                    @cai_expiration_dt, 'UNKNOWN', 'N', '1', '2049-12-31 23:59:00',
                                    0, @tmwuser, GETDATE(), @min_id)

         END
   END

   SELECT @min_id = MIN(cai_id)
     FROM inserted
    WHERE cai_id > @min_id

END

IF (SELECT ISNULL(UPPER(LEFT(gi_string1, 1)), 'N')
      FROM generalinfo
     WHERE gi_name = 'CarrierFileAudit') = 'Y'
BEGIN
   SET @deletedcount = 0
   SELECT @deletedcount = COUNT(*)
     FROM deleted

   --Inserting new row
   IF @deletedcount = 0
   BEGIN
      SELECT @car_id = i.car_id,
             @cai_insurance_type = i.cai_insurance_type
        FROM inserted i
      INSERT INTO carrierinsuranceaudit (car_id, cai_insurance_type, cia_action, cia_update_dt,
                                         cia_update_by)
                                 VALUES (@car_id, @cai_insurance_type, 'INSERT', GETDATE(), @tmwuser)
   END
   ELSE
   --Updating existing row
   BEGIN
      SELECT @car_id = i.car_id,
             @cai_insurance_type = i.cai_insurance_type
        FROM inserted i
      SET @updatedate = GETDATE()

      IF UPDATE(cai_cmpissued)
      BEGIN
         SELECT @oldvalue = ISNULL(d.cai_cmpissued, ' '),
                @newvalue = ISNULL(i.cai_cmpissued, ' ')
           FROM deleted d, inserted i
         IF @oldvalue <> @newvalue
            INSERT INTO carrierinsuranceaudit (car_id, cai_insurance_type, cia_action, cia_update_field,
                                               cia_update_dt, cia_update_by, cia_original_value, cia_new_value)
                                       VALUES (@car_id, @cai_insurance_type, 'UPDATE', 'COMPANY ISSUED',
                                               @updatedate, @tmwuser, @oldvalue, @newvalue)
      END

      IF UPDATE(cai_effective_dt)
      BEGIN
         SELECT @oldvalue = ISNULL(RTRIM(CONVERT(varchar(10), d.cai_effective_dt, 1) + ' ' +  
                                         CONVERT(VARCHAR(13), d.cai_effective_dt, 114)), ' '),
                @newvalue = ISNULL(RTRIM(CONVERT(varchar(10), i.cai_effective_dt, 1) + ' ' +  
                                         CONVERT(VARCHAR(13), i.cai_effective_dt, 114)), ' ')
           FROM deleted d, inserted i
         IF @oldvalue <> @newvalue
            INSERT INTO carrierinsuranceaudit (car_id, cai_insurance_type, cia_action, cia_update_field,
                                               cia_update_dt, cia_update_by, cia_original_value, cia_new_value)
                                       VALUES (@car_id, @cai_insurance_type, 'UPDATE', 'EFFECTIVE DATE',
                                               @updatedate, @tmwuser, @oldvalue, @newvalue)
      END
   
      IF UPDATE(cai_expiration_dt)
      BEGIN
         SELECT @oldvalue = ISNULL(RTRIM(CONVERT(varchar(10), d.cai_expiration_dt, 1) + ' ' +  
                                         CONVERT(VARCHAR(13), d.cai_expiration_dt, 114)), ' '),
                @newvalue = ISNULL(RTRIM(CONVERT(varchar(10), i.cai_expiration_dt, 1) + ' ' +  
                                         CONVERT(VARCHAR(13), i.cai_expiration_dt, 114)), ' ')
           FROM deleted d, inserted i
         IF @oldvalue <> @newvalue
            INSERT INTO carrierinsuranceaudit (car_id, cai_insurance_type, cia_action, cia_update_field,
                                               cia_update_dt, cia_update_by, cia_original_value, cia_new_value)
                                       VALUES (@car_id, @cai_insurance_type, 'UPDATE', 'EXPIRATION DATE',
                                               @updatedate, @tmwuser, @oldvalue, @newvalue)
      END

      IF UPDATE(cai_liability_limit)
      BEGIN
         SELECT @oldvalue = ISNULL(CAST(d.cai_liability_limit AS VARCHAR(20)), ' '),
                @newvalue = ISNULL(CAST(i.cai_liability_limit AS VARCHAR(20)), ' ')
           FROM deleted d, inserted i
         IF @oldvalue <> @newvalue
            INSERT INTO carrierinsuranceaudit (car_id, cai_insurance_type, cia_action, cia_update_field,
                                               cia_update_dt, cia_update_by, cia_original_value, cia_new_value)
                                       VALUES (@car_id, @cai_insurance_type, 'UPDATE', 'LIABILITY LIMIT',
                                               @updatedate, @tmwuser, @oldvalue, @newvalue)
      END

      IF UPDATE(cai_comment)
      BEGIN
         SELECT @oldvalue = ISNULL(d.cai_comment, ' '),
                @newvalue = ISNULL(i.cai_comment, ' ')
           FROM deleted d, inserted i
         IF @oldvalue <> @newvalue
            INSERT INTO carrierinsuranceaudit (car_id, cai_insurance_type, cia_action, cia_update_field,
                                               cia_update_dt, cia_update_by, cia_original_value, cia_new_value)
                                       VALUES (@car_id, @cai_insurance_type, 'UPDATE', 'COMMENT',
                                               @updatedate, @tmwuser, @oldvalue, @newvalue)
      END
   END
END


GO
ALTER TABLE [dbo].[carrierinsurance] ADD CONSTRAINT [pk_carrierinsurance_cai_id] PRIMARY KEY CLUSTERED ([cai_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carrierinsurance_car_id] ON [dbo].[carrierinsurance] ([car_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_carrierinsurance_car_id_type_policy] ON [dbo].[carrierinsurance] ([car_id], [cai_insurance_type], [cai_policynumber]) INCLUDE ([cai_id]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carrierinsurance] TO [public]
GO
GRANT INSERT ON  [dbo].[carrierinsurance] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carrierinsurance] TO [public]
GO
GRANT SELECT ON  [dbo].[carrierinsurance] TO [public]
GO
GRANT UPDATE ON  [dbo].[carrierinsurance] TO [public]
GO
