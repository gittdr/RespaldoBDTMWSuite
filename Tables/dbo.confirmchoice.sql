CREATE TABLE [dbo].[confirmchoice]
(
[confirmchoice_id] [int] NOT NULL IDENTITY(1, 1),
[source_window] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[source_datawindow] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[source_dwcolname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[windowtitle] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[textlength_below] [int] NULL,
[list_dw] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[list_dw_datacolumn] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[retired] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_confirmchoice]
ON [dbo].[confirmchoice]
FOR INSERT,UPDATE
AS  
  
/**
 * 
 * NAME:
 * dbo.itut_confirmchoice
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
 * 01/30/2012 PTS60176 SPN - Initial Version
 **/
DECLARE @tmwuser                 VARCHAR(255)
DECLARE @last_updateby           VARCHAR(255)
DECLARE @last_updatedate         DATETIME

BEGIN
   EXEC gettmwuser @tmwuser OUTPUT

   SELECT @last_updateby = @tmwuser
   SELECT @last_updatedate = GETDATE()

   UPDATE confirmchoice
      SET last_updateby   = @last_updateby
        , last_updatedate = @last_updatedate
    WHERE confirmchoice_id IN (SELECT confirmchoice_id FROM inserted)
END
RETURN
GO
ALTER TABLE [dbo].[confirmchoice] ADD CONSTRAINT [pk_confirmchoice_id] PRIMARY KEY CLUSTERED ([confirmchoice_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[confirmchoice] TO [public]
GO
GRANT INSERT ON  [dbo].[confirmchoice] TO [public]
GO
GRANT REFERENCES ON  [dbo].[confirmchoice] TO [public]
GO
GRANT SELECT ON  [dbo].[confirmchoice] TO [public]
GO
GRANT UPDATE ON  [dbo].[confirmchoice] TO [public]
GO
