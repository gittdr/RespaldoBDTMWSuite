CREATE TABLE [dbo].[passenger]
(
[psgr_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[psgr_firstname] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_lastname] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_middleinitial] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_address1] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_address2] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_city] [int] NULL,
[psgr_ctynmstct] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_state] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_zip] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_gender] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_dateofbirth] [datetime] NULL,
[psgr_citizenship_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_citizenship_country] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_driverlicense] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_licenseclass] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_license_region] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_aceid_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[psgr_aceid_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[dt_passenger] ON [dbo].[passenger] 
FOR DELETE 
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
 if exists 
  ( select * from movepassenger, deleted
     where deleted.psgr_id = movepassenger.psgr_id ) 
   begin
     raiserror('Cannot delete Passenger: Assigned to Movements',16,1)
     rollback transaction
   end
else
begin
	declare @psgr_id varchar(8)
	select @psgr_id = psgr_id from deleted
	
	-- delete
	DELETE FROM driverdocument 
	WHERE mpp_id = @psgr_id
	AND drd_type = 'P'
end
GO
ALTER TABLE [dbo].[passenger] ADD CONSTRAINT [pk_passenger] PRIMARY KEY CLUSTERED ([psgr_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[passenger] TO [public]
GO
GRANT INSERT ON  [dbo].[passenger] TO [public]
GO
GRANT REFERENCES ON  [dbo].[passenger] TO [public]
GO
GRANT SELECT ON  [dbo].[passenger] TO [public]
GO
GRANT UPDATE ON  [dbo].[passenger] TO [public]
GO
