CREATE TABLE [dbo].[osd]
(
[osd_stp_number] [int] NOT NULL,
[osd_sequence] [int] NOT NULL,
[osd_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[osd_ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[osd_ref_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[osd_description] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[osd_mov_number] [int] NOT NULL,
[osd_quantity] [float] NULL,
[osd_quantity_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[osd_responsibility] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[osd_dest_cmp_id] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ord_hdrnumber] [int] NULL,
[osd_id] [int] NOT NULL IDENTITY(1, 1),
[osd_opendate] [datetime] NULL,
[osd_closedate] [datetime] NULL,
[osd_origclaimamount] [money] NULL,
[osd_amtpaid] [money] NULL,
[osd_amtreceived] [money] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  CREATE TRIGGER [dbo].[iut_osd]  
ON [dbo].[osd]  
FOR INSERT, UPDATE
AS  

DECLARE @ord_hdrnumber int,
		@stp_number int,
		@ref_number varchar(30),
		@ref_type varchar(6),
		@osd_id int,
		@max_seq int
		
if exists (SELECT * FROM inserted i left outer join deleted d on i.osd_stp_number = d.osd_stp_number and i.ord_hdrnumber = d.ord_hdrnumber where isnull(i.osd_ref_number, '') <> isnull(d.osd_ref_number, ''))
	BEGIN
		select @osd_id = min(osd_id) from inserted	
		WHILE ISNULL(@osd_id, 0) <> 0
			BEGIN
				select @ord_hdrnumber = ord_hdrnumber, @stp_number = osd_stp_number, @ref_number = osd_ref_number, @ref_type = osd_ref_type from inserted where osd_id = @osd_id
				select @max_seq = max(ref_sequence) from referencenumber WHERE ord_hdrnumber = @ord_hdrnumber and ref_table = 'stops' and ref_tablekey = @stp_number and ref_type = @ref_type
				INSERT INTO referencenumber(ref_tablekey, ref_type, ref_number, ref_typedesc, ref_sequence, ord_hdrnumber, ref_table) 
							 VALUES(@stp_number, @ref_type, @ref_number, '', @max_seq + 1, @ord_hdrnumber, 'stops')

				SELECT @osd_id = min(osd_id) FROM inserted WHERE osd_id > @osd_id
			END
	END

GO
CREATE NONCLUSTERED INDEX [pk_osd] ON [dbo].[osd] ([osd_stp_number], [osd_ref_type], [osd_ref_number]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[osd] TO [public]
GO
GRANT INSERT ON  [dbo].[osd] TO [public]
GO
GRANT REFERENCES ON  [dbo].[osd] TO [public]
GO
GRANT SELECT ON  [dbo].[osd] TO [public]
GO
GRANT UPDATE ON  [dbo].[osd] TO [public]
GO
