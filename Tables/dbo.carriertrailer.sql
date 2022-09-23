CREATE TABLE [dbo].[carriertrailer]
(
[ctrl_id] [int] NOT NULL IDENTITY(1, 1),
[car_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ctrl_trailer_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ctrl_units] [int] NULL,
[ctrl_weight] [decimal] (8, 2) NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_carriertrailer] ON [dbo].[carriertrailer]
FOR DELETE
AS
DECLARE @min_id			INTEGER,
        @car_id			VARCHAR(8),
        @ctrl_trailer_type	VARCHAR(6),
        @count			INTEGER

IF (SELECT UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
      FROM generalinfo
     WHERE gi_name = 'SyncTrlEquipTrlaccessories') = 'Y'
BEGIN
   SET @min_id = 0
   SELECT @min_id = MIN(ctrl_id)
     FROM deleted
    WHERE ctrl_id > @min_id

   WHILE @min_id > 0 
   BEGIN

      IF @min_id IS NULL
         BREAK

      SELECT @car_id = car_id,
             @ctrl_trailer_type = ctrl_trailer_type
        FROM deleted
       WHERE ctrl_id = @min_id

      SET @count = 0
      SELECT @count = Count(*)
        FROM trlaccessories
       WHERE ta_trailer = @car_id AND
             ta_type = @ctrl_trailer_type AND
             ta_source = 'CAR'
      IF @count > 0
         DELETE FROM trlaccessories
            WHERE ta_trailer = @car_id AND
                  ta_type = @ctrl_trailer_type
         
      SELECT @min_id = MIN(ctrl_id)
        FROM deleted
       WHERE ctrl_id > @min_id

   END
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[it_carriertrailer] ON [dbo].[carriertrailer]
FOR INSERT
AS
DECLARE @min_id			INTEGER,
        @car_id			VARCHAR(8),
        @ctrl_trailer_type	VARCHAR(6),
        @ctrl_units		INTEGER,
        @count			INTEGER

IF (SELECT UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
      FROM generalinfo
     WHERE gi_name = 'SyncTrlEquipTrlaccessories') = 'Y'
BEGIN
   SET @min_id = 0
   SELECT @min_id = MIN(ctrl_id)
     FROM inserted
    WHERE ctrl_id > @min_id

   WHILE @min_id > 0 
   BEGIN

      IF @min_id IS NULL
         BREAK

      SELECT @car_id = car_id,
             @ctrl_trailer_type = ctrl_trailer_type,
             @ctrl_units = ctrl_units
        FROM inserted
       WHERE ctrl_id = @min_id

      SET @count = 0
      SELECT @count = Count(*)
        FROM trlaccessories
       WHERE ta_trailer = @car_id AND
             ta_type = @ctrl_trailer_type AND
             ta_source = 'CAR'
      IF @count > 0
         UPDATE trlaccessories
            SET ta_quantity = @ctrl_units
          WHERE ta_trailer = @car_id AND
                ta_type = @ctrl_trailer_type AND
                ta_source = 'CAR'
      ELSE
         INSERT INTO trlaccessories (ta_type, ta_trailer, ta_quantity, ta_id, ta_source)
                             VALUES (@ctrl_trailer_type, @car_id, @ctrl_units, ' ', 'CAR')
   
      SELECT @min_id = MIN(ctrl_id)
        FROM inserted
       WHERE ctrl_id > @min_id

   END
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_carriertrailer] ON [dbo].[carriertrailer]
FOR UPDATE
AS
DECLARE @min_id			INTEGER,
        @car_id			VARCHAR(8),
        @orig_ctrl_trailer_type	VARCHAR(6),
	@new_ctrl_trailer_type	VARCHAR(6),
        @ctrl_units		INTEGER,
        @count			INTEGER

IF (SELECT UPPER(LEFT(ISNULL(gi_string1, 'N'), 1))
      FROM generalinfo
     WHERE gi_name = 'SyncTrlEquipTrlaccessories') = 'Y'
BEGIN
   SET @min_id = 0
   SELECT @min_id = MIN(ctrl_id)
     FROM inserted
    WHERE ctrl_id > @min_id

   WHILE @min_id > 0 
   BEGIN

      IF @min_id IS NULL
         BREAK

      SELECT @car_id = car_id,
             @orig_ctrl_trailer_type = ctrl_trailer_type
        FROM deleted
       WHERE ctrl_id = @min_id

      SELECT @new_ctrl_trailer_type = ctrl_trailer_type,
             @ctrl_units = ctrl_units
        FROM inserted
       WHERE ctrl_id = @min_id

      SET @count = 0
      SELECT @count = Count(*)
        FROM trlaccessories
       WHERE ta_trailer = @car_id AND
             ta_type = @orig_ctrl_trailer_type AND
             ta_source = 'CAR'
      IF @count > 0
         UPDATE trlaccessories
            SET ta_quantity = @ctrl_units,
                ta_type = @new_ctrl_trailer_type
          WHERE ta_trailer = @car_id AND
                ta_type = @orig_ctrl_trailer_type AND
                ta_source = 'CAR'
        
      SELECT @min_id = MIN(ctrl_id)
        FROM inserted
       WHERE ctrl_id > @min_id

   END
END

GO
ALTER TABLE [dbo].[carriertrailer] ADD CONSTRAINT [pk_carriertrailer_ctrl_id] PRIMARY KEY CLUSTERED ([ctrl_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_carriertrailer_car_id] ON [dbo].[carriertrailer] ([car_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[carriertrailer] TO [public]
GO
GRANT INSERT ON  [dbo].[carriertrailer] TO [public]
GO
GRANT REFERENCES ON  [dbo].[carriertrailer] TO [public]
GO
GRANT SELECT ON  [dbo].[carriertrailer] TO [public]
GO
GRANT UPDATE ON  [dbo].[carriertrailer] TO [public]
GO
