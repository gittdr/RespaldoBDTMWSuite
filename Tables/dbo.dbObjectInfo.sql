CREATE TABLE [dbo].[dbObjectInfo]
(
[Object_ID] [int] NOT NULL IDENTITY(1, 1),
[Object_Type] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_dbObjectInfo_Object_Type] DEFAULT ('TABLE'),
[Object_PhysicalName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Object_LogicalName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_dbObjectInfo]
ON [dbo].[dbObjectInfo]
FOR INSERT,UPDATE
AS

/**
 *
 * NAME:
 * dbo.itut_dbObjectInfo
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * This trigger updates userid, last update date
 *
 * RETURNS:
 * None
 *
 * RESULT SETS:
 * NONE.
 *
 * PARAMETERS:
 * NONE
 *
 * REFERENCES:

 *
 * REVISION HISTORY:
 * 04/13/2012 PTS62240 SPN - Initial Version
 **/
DECLARE @tmwuser                 VARCHAR(255)
DECLARE @last_updateby           VARCHAR(255)
DECLARE @last_updatedate         DATETIME

BEGIN
   EXEC gettmwuser @tmwuser OUTPUT

   SELECT @last_updateby = @tmwuser
   SELECT @last_updatedate = GETDATE()

   UPDATE dbObjectInfo
      SET last_updateby   = @last_updateby
        , last_updatedate = @last_updatedate
    WHERE Object_ID IN (SELECT Object_ID FROM inserted)
END
RETURN
GO
ALTER TABLE [dbo].[dbObjectInfo] ADD CONSTRAINT [pk_dbObjectInfo_id] PRIMARY KEY CLUSTERED ([Object_ID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [idx01] ON [dbo].[dbObjectInfo] ([Object_PhysicalName], [Object_Type]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[dbObjectInfo] TO [public]
GO
GRANT INSERT ON  [dbo].[dbObjectInfo] TO [public]
GO
GRANT REFERENCES ON  [dbo].[dbObjectInfo] TO [public]
GO
GRANT SELECT ON  [dbo].[dbObjectInfo] TO [public]
GO
GRANT UPDATE ON  [dbo].[dbObjectInfo] TO [public]
GO
