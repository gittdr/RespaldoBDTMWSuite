CREATE TABLE [dbo].[trlaccessories]
(
[ta_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ta_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ta_cost] [float] NULL,
[ta_hours] [int] NULL,
[ta_dateacquired] [datetime] NULL,
[ta_opercost] [float] NULL,
[ta_fueltype] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ta_trailer] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[timestamp] [timestamp] NULL,
[ta_quantity] [int] NULL,
[ta_expire_date] [datetime] NULL,
[ta_expire_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ta_source] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[trlaccessory_id] [int] NOT NULL IDENTITY(1, 1),
[ta_field] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ta_value] [decimal] (10, 2) NULL,
[ta_units] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*   MODIFICATIONS

-- 8/8/2006 PTS 33485 BDH - Added ta_source column to trlaccessories to distinguish between trailers and carrier trailers.

*/

CREATE TRIGGER [dbo].[dt_trlaccessories] ON [dbo].[trlaccessories]
FOR DELETE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE @accessorylist varchar(254),
	@nextaccessory varchar(10),
	@trailer	varchar(12)

begin	
   SELECT @nextaccessory = '',
	  @accessorylist = ''

   SELECT @trailer = min(ta_trailer) from deleted

   WHILE 1=1
   BEGIN
	SELECT @nextaccessory = min(ta_type)
	FROM	trlaccessories
	WHERE	ta_type > @nextaccessory AND
		ta_trailer = @trailer AND
		ta_type NOT IN (SELECT ta_type
				from deleted)
		-- 33485 BDH (start)
		and upper(ta_source) = 'TRL'
		-- 33485 BDH (end)

	If @nextaccessory is null BREAK
	SELECT @accessorylist = @accessorylist + ',,' + @nextaccessory
   END


SELECT @accessorylist = @accessorylist + ',,'

If @accessorylist = ',,' or @accessorylist = ',,,,'
   UPDATE trailerprofile
   SET	  trl_accessorylist = ''
   FROM	  DELETED
   WHERE  deleted.ta_trailer = trailerprofile.trl_id
ELSE
   UPDATE trailerprofile
   SET	  trl_accessorylist = @accessorylist
   FROM	  DELETED
   WHERE  deleted.ta_trailer = trailerprofile.trl_id
	  
end 

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*   MODIFICATIONS

-- 8/8/2006 PTS 33485 BDH - Added ta_source column to trlaccessories to distinguish between trailers and carrier trailers.

*/

CREATE TRIGGER [dbo].[iut_traileraccessories] ON [dbo].[trlaccessories]
FOR INSERT, UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE @accessorylist varchar(254),
	@nextaccessory varchar(10),
	@trailer	varchar(12)

begin	
   SELECT @nextaccessory = '',
	  @accessorylist = ''

   SELECT @trailer= min(ta_trailer) from inserted

   WHILE 1=1
   BEGIN
	SELECT @nextaccessory = min(ta_type)
	FROM	trlaccessories
	WHERE	ta_type > @nextaccessory AND
		ta_trailer = @trailer
-- PTS 18488 -- BL (start)
	and ta_expire_date >= getdate()
-- PTS 18488 -- BL (end)
-- PTS 33485 -- BDH (start)
	and upper(ta_source) = 'TRL'
-- PTS 33485 -- BDH (end)


	If @nextaccessory is null BREAK
	SELECT @accessorylist = @accessorylist + ',,' + @nextaccessory
   END


SELECT @accessorylist = @accessorylist + ',,'

UPDATE trailerprofile
SET	trl_accessorylist = @accessorylist
FROM	inserted
WHERE	inserted.ta_trailer = trailerprofile.trl_id AND
	@accessorylist <> IsNull(trl_accessorylist, '')
	  
end 

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create TRIGGER [dbo].[trlaccessories_Insert_JR]
ON [dbo].[trlaccessories]
AFTER INSERT 
AS 
DECLARE @usr char(30) SET @usr = user
IF ( UPDATE (ta_quantity) )
BEGIN
INSERT INTO trlaccessoriesHist 
	(ta_type_h, 
ta_trailer_h, 
ta_fecha_h, 
ta_quantity_h, 
ta_quantity_ant_h, 
ta_source_h, 
ta_usuario_h)
	select 
D.ta_type, 
D.ta_trailer,
getdate() , 
TA.ta_quantity, 
0,
D.ta_source,@usr
	from Inserted D,trlaccessories TA
	where D.trlaccessory_id = TA.trlaccessory_id; 
END;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[trlaccessories_Update_JR]
ON [dbo].[trlaccessories]
AFTER UPDATE 
AS 
DECLARE @usr char(30) SET @usr = user
IF ( UPDATE (ta_quantity) )
BEGIN
INSERT INTO trlaccessoriesHist 
	(ta_type_h, ta_trailer_h,ta_fecha_h,ta_quantity_h,ta_quantity_ant_h,ta_source_h,ta_usuario_h)
	select D.ta_type, D.ta_trailer,getdate() ,TA.ta_quantity,D.ta_quantity,D.ta_source,@usr
	from deleted D,trlaccessories TA
	where D.trlaccessory_id = TA.trlaccessory_id; 
END;
GO
ALTER TABLE [dbo].[trlaccessories] ADD CONSTRAINT [pk_trlaccessories] PRIMARY KEY CLUSTERED ([trlaccessory_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_ta] ON [dbo].[trlaccessories] ([ta_trailer], [ta_type], [ta_source]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[trlaccessories] TO [public]
GO
GRANT INSERT ON  [dbo].[trlaccessories] TO [public]
GO
GRANT REFERENCES ON  [dbo].[trlaccessories] TO [public]
GO
GRANT SELECT ON  [dbo].[trlaccessories] TO [public]
GO
GRANT UPDATE ON  [dbo].[trlaccessories] TO [public]
GO
