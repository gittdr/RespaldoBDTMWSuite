CREATE TABLE [dbo].[tblResourceProperties]
(
[SN] [int] NOT NULL IDENTITY(1, 1),
[PropMCSN] [int] NOT NULL,
[ResourceSN] [int] NOT NULL,
[ResourceType] [int] NOT NULL,
[Value] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[tm_update_drivertruck_modifyed]
ON [dbo].[tblResourceProperties]
FOR INSERT, UPDATE ,DELETE
AS 

/**
 * 
 * NAME:
 * dbo.tm_update_driver_modifyed
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * UPdates the modifyed date for Trucks and Drivers when propertys change
 * 
 * 
 * Change Log: 
 * rwolfe inti 5/31/2013
 * removed due deadlock created from configuration driver update
 * rwolfe 9/5/2013 adding back in and fixing deadlock issue to improve XRS efficency pts 71730
 *
 **/

Set NOCOUNT ON

--on any change go back to the driver in tbldrivers or the truck in tbltrucks and update the modifyed feild to now

UPDATE dbo.tblDrivers
SET updated_on = GETDATE()
WHERE SN IN (SELECT DISTINCT INSERTED.ResourceSN FROM INSERTED JOIN DELETED ON INSERTED.ResourceSN = DELETED.ResourceSN
			WHERE INSERTED.ResourceType = 5);
			
UPDATE dbo.tblTrucks
SET updated_on = GETDATE()
WHERE SN IN (SELECT DISTINCT INSERTED.ResourceSN FROM INSERTED JOIN DELETED ON INSERTED.ResourceSN = DELETED.ResourceSN
			WHERE INSERTED.ResourceType = 4);
GO
ALTER TABLE [dbo].[tblResourceProperties] ADD CONSTRAINT [PK_tblResourceProperties] PRIMARY KEY CLUSTERED ([SN]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[tblResourceProperties] TO [public]
GO
GRANT INSERT ON  [dbo].[tblResourceProperties] TO [public]
GO
GRANT REFERENCES ON  [dbo].[tblResourceProperties] TO [public]
GO
GRANT SELECT ON  [dbo].[tblResourceProperties] TO [public]
GO
GRANT UPDATE ON  [dbo].[tblResourceProperties] TO [public]
GO
