CREATE TABLE [dbo].[intelli_dddw]
(
[intelli_dddw_id] [int] NOT NULL IDENTITY(1, 1),
[window] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[datawindow] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dwcolname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dddw_name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dddw_displaycolumn] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dddw_datacolumn] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_intelli_dddw]
ON [dbo].[intelli_dddw]
FOR INSERT,UPDATE
AS  
  
/**
 * 
 * NAME:
 * dbo.itut_intelli_dddw
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
 * 05/25/2011 PTS56318 SPN - Initial Version
 **/
DECLARE @tmwuser                 VARCHAR(255)
DECLARE @last_updateby           VARCHAR(255)
DECLARE @last_updatedate         DATETIME

BEGIN
   EXEC gettmwuser @tmwuser OUTPUT

   SELECT @last_updateby = @tmwuser
   SELECT @last_updatedate = GETDATE()

   UPDATE intelli_dddw
      SET last_updateby   = @last_updateby
        , last_updatedate = @last_updatedate
    WHERE intelli_dddw_id IN (SELECT intelli_dddw_id FROM inserted)
END
RETURN
GO
ALTER TABLE [dbo].[intelli_dddw] ADD CONSTRAINT [pk_intelli_dddw_id] PRIMARY KEY CLUSTERED ([intelli_dddw_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[intelli_dddw] TO [public]
GO
GRANT INSERT ON  [dbo].[intelli_dddw] TO [public]
GO
GRANT REFERENCES ON  [dbo].[intelli_dddw] TO [public]
GO
GRANT SELECT ON  [dbo].[intelli_dddw] TO [public]
GO
GRANT UPDATE ON  [dbo].[intelli_dddw] TO [public]
GO
