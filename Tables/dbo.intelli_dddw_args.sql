CREATE TABLE [dbo].[intelli_dddw_args]
(
[intelli_dddw_args_id] [int] NOT NULL IDENTITY(1, 1),
[intelli_dddw_id] [int] NOT NULL,
[seqno] [int] NOT NULL,
[arg] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[last_updateby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_updatedate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_intelli_dddw_args]
ON [dbo].[intelli_dddw_args]
FOR INSERT,UPDATE
AS  
  
/**
 * 
 * NAME:
 * dbo.itut_intelli_dddw_args
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

   UPDATE intelli_dddw_args
      SET last_updateby   = @last_updateby
        , last_updatedate = @last_updatedate
    WHERE intelli_dddw_args_id IN (SELECT intelli_dddw_args_id FROM inserted)
END
RETURN
GO
ALTER TABLE [dbo].[intelli_dddw_args] ADD CONSTRAINT [pk_intelli_dddw_args_id] PRIMARY KEY CLUSTERED ([intelli_dddw_args_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[intelli_dddw_args] ADD CONSTRAINT [fk_intelli_dddw_args_intelli_dddw_id] FOREIGN KEY ([intelli_dddw_id]) REFERENCES [dbo].[intelli_dddw] ([intelli_dddw_id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[intelli_dddw_args] TO [public]
GO
GRANT INSERT ON  [dbo].[intelli_dddw_args] TO [public]
GO
GRANT REFERENCES ON  [dbo].[intelli_dddw_args] TO [public]
GO
GRANT SELECT ON  [dbo].[intelli_dddw_args] TO [public]
GO
GRANT UPDATE ON  [dbo].[intelli_dddw_args] TO [public]
GO
