CREATE TABLE [dbo].[standingdeductiontblratehdr]
(
[sdh_number] [int] NOT NULL,
[sdh_name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sdh_ratetype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sdh_createdby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdh_createddate] [datetime] NULL,
[sdh_updatedby] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sdh_updateddate] [datetime] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[itut_standingdeductiontblratehdr] ON [dbo].[standingdeductiontblratehdr] 
FOR INSERT, UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

declare @ll_update int,@ll_sdh_number int

--PTS 23691 CGK 9/3/2004
DECLARE @tmwuser varchar (255)
exec gettmwuser @tmwuser output

select @ll_update = count(*) from deleted
select @ll_sdh_number = sdh_number from inserted
IF @ll_update = 0 -- insert
    update standingdeductiontblratehdr set sdh_createdby = @tmwuser , sdh_createddate = getdate(),
    sdh_updatedby = @tmwuser ,sdh_updateddate = getdate() where sdh_number = @ll_sdh_number
Else -- update
   update standingdeductiontblratehdr set 
    sdh_updatedby = @tmwuser ,sdh_updateddate = getdate() where sdh_number = @ll_sdh_number


GO
ALTER TABLE [dbo].[standingdeductiontblratehdr] ADD CONSTRAINT [PK_tariffstlcollectheader] PRIMARY KEY CLUSTERED ([sdh_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[standingdeductiontblratehdr] TO [public]
GO
GRANT INSERT ON  [dbo].[standingdeductiontblratehdr] TO [public]
GO
GRANT REFERENCES ON  [dbo].[standingdeductiontblratehdr] TO [public]
GO
GRANT SELECT ON  [dbo].[standingdeductiontblratehdr] TO [public]
GO
GRANT UPDATE ON  [dbo].[standingdeductiontblratehdr] TO [public]
GO
