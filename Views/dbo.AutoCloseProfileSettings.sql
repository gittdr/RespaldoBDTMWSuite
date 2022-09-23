SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[AutoCloseProfileSettings]
AS 
select mpp_ms_id as id ,Resource_type,Resource_id,AutoCloseStatus,lastupdateby,lastupdatedate from [dbo].[ManpowerProfile_moreSettings]
Union all
select car_ms_id as id ,Resource_type,Resource_id,AutoCloseStatus,lastupdateby,lastupdatedate   from [dbo].[carrier_moreSettings]

Union all
select trc_ms_id as id ,Resource_type,Resource_id,AutoCloseStatus,lastupdateby,lastupdatedate  from [dbo].[tractorprofile_moreSettings] 

GO
GRANT DELETE ON  [dbo].[AutoCloseProfileSettings] TO [public]
GO
GRANT INSERT ON  [dbo].[AutoCloseProfileSettings] TO [public]
GO
GRANT SELECT ON  [dbo].[AutoCloseProfileSettings] TO [public]
GO
GRANT UPDATE ON  [dbo].[AutoCloseProfileSettings] TO [public]
GO
