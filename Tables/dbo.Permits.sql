CREATE TABLE [dbo].[Permits]
(
[P_ID] [int] NOT NULL IDENTITY(1, 1),
[PM_ID] [int] NOT NULL,
[PRT_ID] [int] NULL,
[ord_hdrnumber] [int] NULL,
[mov_number] [int] NULL,
[lgh_number] [int] NULL,
[asgn_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[asgn_id] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P_Status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P_Valid_From] [datetime] NULL,
[P_Valid_To] [datetime] NULL,
[P_Permit_Number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P_OrderedDate] [datetime] NULL,
[P_ReceivedDate] [datetime] NULL,
[P_TransmitDate] [datetime] NULL,
[P_Cost] [money] NULL,
[P_TransmitBy] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PE_ID] [int] NULL,
[P_Escort_Meet_At] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P_Escort_Leave_At] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P_Escort_Cost] [money] NULL,
[P_Escort_Qty] [smallint] NULL,
[P_Transmit_To_Type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P_Transmit_To] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P_Transmit_Method] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P_Comment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P_Original_P_ID] [int] NULL,
[P_Rev_Reason_Code] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P_Rev_Comment] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P_Max_Width] [float] NULL,
[P_Max_Length] [float] NULL,
[P_Max_Height] [float] NULL,
[P_Max_Weight] [float] NULL,
[P_Number_Axles] [smallint] NULL,
[P_Cmd_Comment1] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P_Cmd_Comment2] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[P_Cmd_Comment3] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[p_createdate] [datetime] NULL,
[p_createby] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[p_ordered_height] [float] NULL,
[p_ordered_width] [float] NULL,
[p_uiseq] [int] NULL,
[p_comdata_comment] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[p_timestamp] [timestamp] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[it_permits] ON [dbo].[Permits]
FOR INSERT
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
  Begin

    declare @v_tmwuser varchar(255)
    exec gettmwuser @v_tmwuser output    

    update permits
       set p_createdate = getdate(),
           p_createby = @v_tmwuser
      from inserted
    where inserted.p_id = permits.p_id
  end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[itutpermits] ON [dbo].[Permits]
FOR INSERT,UPDATE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 
  Begin
    declare @v_orig_p_id int, @v_p_id int
    if (select count(1) from inserted) > 1
      RETURN

    select @v_orig_p_id = P_Original_P_ID,
           @v_p_id = P_ID
      from inserted

    if isnull(@v_orig_p_id,0) = 0
       update permits
          set P_Original_P_ID = P_ID
        where P_ID = @v_p_id
  end
GO
ALTER TABLE [dbo].[Permits] ADD CONSTRAINT [PK_Permits] PRIMARY KEY CLUSTERED ([P_ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_permits_mov_number] ON [dbo].[Permits] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Permits_P_Original_P_ID] ON [dbo].[Permits] ([P_Original_P_ID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Permits] ADD CONSTRAINT [FK_Permits_Permit_Escorts] FOREIGN KEY ([PE_ID]) REFERENCES [dbo].[Permit_Escorts] ([PE_ID])
GO
ALTER TABLE [dbo].[Permits] ADD CONSTRAINT [FK_Permits_Permit_Master] FOREIGN KEY ([PM_ID]) REFERENCES [dbo].[Permit_Master] ([PM_ID])
GO
ALTER TABLE [dbo].[Permits] ADD CONSTRAINT [FK_Permits_Permit_Route] FOREIGN KEY ([PRT_ID]) REFERENCES [dbo].[Permit_Route] ([PRT_ID])
GO
ALTER TABLE [dbo].[Permits] WITH NOCHECK ADD CONSTRAINT [FK_Permits_Permits] FOREIGN KEY ([P_Original_P_ID]) REFERENCES [dbo].[Permits] ([P_ID])
GO
ALTER TABLE [dbo].[Permits] NOCHECK CONSTRAINT [FK_Permits_Permits]
GO
GRANT DELETE ON  [dbo].[Permits] TO [public]
GO
GRANT INSERT ON  [dbo].[Permits] TO [public]
GO
GRANT REFERENCES ON  [dbo].[Permits] TO [public]
GO
GRANT SELECT ON  [dbo].[Permits] TO [public]
GO
GRANT UPDATE ON  [dbo].[Permits] TO [public]
GO
