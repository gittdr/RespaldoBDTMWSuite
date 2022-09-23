CREATE TABLE [dbo].[driverqualifications]
(
[drq_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drq_id] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drq_date] [datetime] NULL,
[drq_driver] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[timestamp] [timestamp] NULL,
[drq_quantity] [tinyint] NULL,
[drq_expire_date] [datetime] NULL,
[drq_expire_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drq_source] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[driverqualification_id] [int] NOT NULL IDENTITY(1, 1),
[drq_field] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[drq_value] [decimal] (10, 2) NULL,
[drq_units] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*   MODIFICATION
8/8/2006 PTS 33485 BDH - Added drq_source column to driverqualifications to distinguish between drivers and carriers.
*/

CREATE TRIGGER [dbo].[dt_driverqualifications] ON [dbo].[driverqualifications]
FOR DELETE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

DECLARE @qualificationlist varchar(254),
	@nextqualification varchar(10),
	@driver	varchar(12)

SELECT @driver = min(drq_driver) from deleted
while @driver is not null 
begin
	SELECT @nextqualification = '', @qualificationlist = ''
	WHILE 1=1
	BEGIN
		SELECT @nextqualification = min(drq_type)
		FROM	driverqualifications
		WHERE	drq_type > @nextqualification 
		  AND drq_driver = @driver 
		  and drq_type NOT IN (SELECT drq_type from deleted)
		  and upper(drq_source) = 'DRV'

		If @nextqualification is null BREAK
		SELECT @qualificationlist = @qualificationlist + ',,' + @nextqualification
	END

	SELECT @qualificationlist = @qualificationlist + ',,'

	If @qualificationlist = ',,' or @qualificationlist = ',,,,'
		UPDATE manpowerprofile
			SET	  mpp_qualificationlist = ''
			FROM  DELETED
			WHERE  @driver = manpowerprofile.mpp_id
	ELSE
		UPDATE manpowerprofile
			SET	mpp_qualificationlist = @qualificationlist
			FROM	deleted
			WHERE	@driver = manpowerprofile.mpp_id 
	SELECT @driver = min(drq_driver) from deleted where drq_driver > @driver 
END 

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*   MODIFICATION
8/8/2006 PTS 33485 BDH - Added drq_source column to driverqualifications to distinguish between drivers and carriers.
*/

create trigger [dbo].[iut_driverqualifications] on [dbo].[driverqualifications]
for insert, update
as
set nocount on; 
declare @qualificationlist as varchar (254), 
		@nextqualification as varchar (10), 
		@driver as varchar (12);
select @driver = min(drq_driver) from inserted;
while @driver is not null
   begin
       select @nextqualification = '', @qualificationlist = '';
       while 1 = 1
           begin
               select @nextqualification = min(drq_type)
               from   driverqualifications
               where  drq_type > @nextqualification
                      and drq_driver = @driver
                      and drq_expire_date >= getdate()
                      and upper(drq_source) = 'DRV';
               if @nextqualification is null
                   break;
               select @qualificationlist = @qualificationlist + ',,' + @nextqualification;
           end
       select @qualificationlist = @qualificationlist + ',,';
       update  manpowerprofile
           set mpp_qualificationlist = @qualificationlist
       from    inserted
       where   inserted.drq_driver = manpowerprofile.mpp_id
               and @qualificationlist <> IsNull(mpp_qualificationlist, '')
               and mpp_id = @driver;
       select @driver = min(drq_driver) from inserted where drq_driver > @driver;
   end

GO
ALTER TABLE [dbo].[driverqualifications] ADD CONSTRAINT [pk_driverqualifications] PRIMARY KEY CLUSTERED ([driverqualification_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [pk_drq_type] ON [dbo].[driverqualifications] ([drq_type], [drq_driver], [drq_source]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[driverqualifications] TO [public]
GO
GRANT INSERT ON  [dbo].[driverqualifications] TO [public]
GO
GRANT REFERENCES ON  [dbo].[driverqualifications] TO [public]
GO
GRANT SELECT ON  [dbo].[driverqualifications] TO [public]
GO
GRANT UPDATE ON  [dbo].[driverqualifications] TO [public]
GO
