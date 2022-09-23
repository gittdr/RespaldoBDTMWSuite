CREATE TABLE [dbo].[cargo_entry]
(
[ce_id] [int] NOT NULL IDENTITY(1, 1),
[ord_hdrnumber] [int] NULL,
[ce_stp_number] [int] NOT NULL,
[ce_type] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ce_ref_type] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_ref_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_description] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_mov_number] [int] NOT NULL,
[ce_quantity] [float] NULL,
[ce_quantity_unit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_responsibility] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_dest_cmp_id] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ce_seal_number] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pyd_number] [int] NULL,
[ivd_number] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  CREATE TRIGGER [dbo].[iut_cargo_entry]  
ON [dbo].[cargo_entry]  
FOR INSERT, UPDATE
AS  

DECLARE @ord_hdrnumber int,
		@stp_number int,
		@ref_number varchar(30),
		@ref_type varchar(6),
		@seal_number varchar(30),
		@ce_id int,
		@max_seq int
		
if exists (SELECT * FROM inserted i left outer join deleted d on i.ce_stp_number = d.ce_stp_number and i.ord_hdrnumber = d.ord_hdrnumber where isnull(i.ce_ref_number, '') <> isnull(d.ce_ref_number, ''))
	BEGIN
		select @ce_id = min(ce_id) from inserted	
		WHILE ISNULL(@ce_id, 0) <> 0
			BEGIN
				select @ord_hdrnumber = ord_hdrnumber, @stp_number = ce_stp_number, @ref_number = ce_ref_number, @ref_type = ce_ref_type, @seal_number = ce_seal_number from inserted where ce_id = @ce_id
				select @max_seq = isNull(max(ref_sequence),0) from referencenumber WHERE ord_hdrnumber = @ord_hdrnumber and ref_table = 'stops' and ref_tablekey = @stp_number
				
				if isnull(@ref_number,'') <> ''
				BEGIN
					if not Exists (select null from referencenumber WHERE ord_hdrnumber = @ord_hdrnumber and ref_table = 'stops' and ref_tablekey = @stp_number and ref_type = @ref_type and ref_number = @ref_number)
						INSERT INTO referencenumber(ref_tablekey, ref_type, ref_number, ref_typedesc, ref_sequence, ord_hdrnumber, ref_table) 
								 VALUES(@stp_number, @ref_type, @ref_number, '', @max_seq + 1, @ord_hdrnumber, 'stops')

					if @max_seq = 0
						UPDATE Stops SET stp_reftype = @ref_type, stp_refnum = @ref_number WHERE stp_number = @stp_number
				END

				IF ISNULL(@seal_number,'') <> ''
					BEGIN
						select @max_seq = isNull(max(ref_sequence),0) from referencenumber WHERE ord_hdrnumber = @ord_hdrnumber and ref_table = 'stops' and ref_tablekey = @stp_number
						IF EXISTS (SELECT NULL FROM referencenumber where ord_hdrnumber = @ord_hdrnumber and ref_table = 'stops' and ref_tablekey = @stp_number and ref_type = 'SEAL')
							BEGIN
								UPDATE referencenumber set ref_number = @seal_number where ord_hdrnumber = @ord_hdrnumber and ref_table = 'stops' and ref_tablekey = @stp_number and ref_type = 'SEAL'
							END
						ELSE
							BEGIN
								INSERT INTO referencenumber(ref_tablekey, ref_type, ref_number, ref_typedesc, ref_sequence, ord_hdrnumber, ref_table) 
									VALUES(@stp_number, 'SEAL', @seal_number, '', @max_seq + 1, @ord_hdrnumber, 'stops')
							END

						select @max_seq = isNull(max(ref_sequence),0) from referencenumber WHERE ord_hdrnumber = @ord_hdrnumber and ref_table = 'stops' and ref_tablekey = @stp_number
		
						if @max_seq = 1
							UPDATE Stops SET stp_reftype = 'SEAL', stp_refnum = @seal_number WHERE stp_number = @stp_number
					END

				SELECT @ce_id = min(ce_id) FROM inserted WHERE ce_id > @ce_id
			END
	END

GO
ALTER TABLE [dbo].[cargo_entry] ADD CONSTRAINT [pk_trailer_cargo_entry] PRIMARY KEY CLUSTERED ([ce_id]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[cargo_entry] TO [public]
GO
GRANT INSERT ON  [dbo].[cargo_entry] TO [public]
GO
GRANT REFERENCES ON  [dbo].[cargo_entry] TO [public]
GO
GRANT SELECT ON  [dbo].[cargo_entry] TO [public]
GO
GRANT UPDATE ON  [dbo].[cargo_entry] TO [public]
GO
