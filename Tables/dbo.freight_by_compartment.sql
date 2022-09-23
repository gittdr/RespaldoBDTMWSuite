CREATE TABLE [dbo].[freight_by_compartment]
(
[fbc_id] [int] NOT NULL,
[fgt_number] [int] NOT NULL,
[stp_number] [int] NULL,
[cmd_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fgt_description] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ecd_id] [int] NULL,
[fbc_compartm_number] [int] NULL,
[fbc_volume] [float] NULL,
[fbc_weight] [float] NULL,
[cpr_density] [decimal] (9, 4) NULL,
[ord_hdrnumber] [int] NULL,
[mov_number] [int] NULL,
[fbc_adj_max_weight] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fbc_consignee] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fbc_compartm_from] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fbc_tank_nbr] [int] NULL,
[scm_subcode] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fbc_volume_net] [real] NULL,
[fbc_load_location] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[stp_number_load] [int] NULL,
[fbc_compartm_capacity] [float] NULL,
[fbc_refnumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tank_loc] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dip_before] [int] NULL,
[dip_after] [int] NULL,
[fbc_net_volume] [float] NULL,
[fbc_delivered] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fbc_max_weight] [decimal] (18, 4) NULL,
[fbc_volumeunitweight] [float] NULL,
[fbc_overloadpercent] [decimal] (6, 3) NULL,
[fbc_retain] [int] NULL,
[fbc_runout] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[fbc_beforegallons] [int] NULL,
[fbc_aftergallons] [int] NULL,
[fbc_water] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE              trigger [dbo].[DT_fbc]
on [dbo].[freight_by_compartment]
for delete
as
SET NOCOUNT ON
DECLARE @reftype VARCHAR(6)
	, @seq INT

BEGIN
	SELECT @reftype = gi_string1 FROM generalinfo WHERE gi_name = 'RefType-Manifest'

	-- find the sequence of the one deleted
	SELECT @seq = MIN(referencenumber.ref_sequence )
	FROM deleted, referencenumber
	WHERE ref_table = 'orderheader'
	AND	ref_type = @reftype
	AND	ref_tablekey = deleted.ord_hdrnumber
	AND	ref_number = deleted.fbc_refnumber

	-- delete the one deleted
	DELETE referencenumber
	FROM deleted
	WHERE ref_tablekey = deleted.ord_hdrnumber
	AND	ref_table = 'orderheader'
	AND	ref_number = deleted.fbc_refnumber
	AND	ref_type = @reftype
	AND	ref_sequence = @seq

	-- resequence remainig refnums
	UPDATE referencenumber 
	SET ref_sequence = ref_sequence - 1
	FROM deleted
	WHERE ref_table = 'orderheader'
	AND	ref_tablekey = deleted.ord_hdrnumber
	AND 	ref_sequence > @seq

	-- ensure that the remaining refnums start w/ sequence of 1
	SELECT @seq = MIN(ref_sequence)
	FROM inserted, referencenumber
	WHERE ref_tablekey = inserted.ord_hdrnumber
	AND	ref_table = 'orderheader'

	IF @seq > 1
		UPDATE referencenumber
		SET ref_sequence = 1
		FROM inserted
		WHERE ref_tablekey = inserted.ord_hdrnumber
		AND	ref_table = 'orderheader'
		AND ref_sequence = @seq

	-- update orderheader to match first ref num
	IF EXISTS(SELECT * FROM referencenumber, inserted WHERE ref_table = 'orderheader' AND ref_tablekey = inserted.ord_hdrnumber)
		UPDATE orderheader
		SET  ord_refnum = ref_number
			, ord_reftype = ref_type
		FROM referencenumber, inserted
		WHERE ref_tablekey = inserted.ord_hdrnumber
		AND	ref_table = 'orderheader'
		AND	ref_sequence = 1
		AND 	orderheader.ord_hdrnumber = inserted.ord_hdrnumber
	ELSE
		UPDATE orderheader
		SET ord_refnum = ''
		FROM inserted
		WHERE inserted.ord_hdrnumber = orderheader.ord_hdrnumber
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*********REMOVE CODE AT BOTTOM AFTER NEXT EDIT *********************/


CREATE trigger [dbo].[IUT_fbc]
ON [dbo].[freight_by_compartment]
FOR insert,update
AS
SET NOCOUNT ON
DECLARE @reftype VARCHAR(6)
	, @seq INT
        ,@vol  int /* 27505 */
/*

DPETE 27362 update tankdiphistory
DPETE 27505 update tankdiphitory delivered qty when fbc_delivered flag set to Y
DPETE 32630 do not update tankdiphistory delivered quantity from here, instead use new dl_delivervolume from diplog
DPETE 33089 (temp) if tank_nbr is set, but fbc_tank_loc is not, fill out the fbc_tank_loc
DPETE  33705 dip readings must also come form editing them on the Freight_by_compartment screen
  07/13/06 JEA request we just plug zero for sales on after dip
 DPETE 36487 3/2/7 put in corrections made by Brad Barker at Pauls
 DPETE 43036 add PTS41420 requires
*/
If update (tank_loc)
 BEGIN
   declare @tanknbr int
   Select @tanknbr = fbc_tank_nbr from inserted
   If @tanknbr is null or @tanknbr = 0 
     BEGIN
       Select @tanknbr =  tank_nbr from tank,inserted
       where tank.cmp_id = fbc_consignee
       and tank.tank_loc = inserted.tank_loc

       If @tanknbr > 0 
         update freight_by_compartment
         set fbc_tank_nbr = @tanknbr
         where fbc_id = (select fbc_id from inserted)
      END

 END

IF UPDATE (fbc_refnumber)
BEGIN
	SELECT @reftype = gi_string1 FROM generalinfo WHERE gi_name = 'RefType-Manifest'

	-- find the sequence of the one edited
	SELECT @seq = MIN(referencenumber.ref_sequence )
	FROM deleted, referencenumber
	WHERE ref_table = 'orderheader'
	AND	ref_type = @reftype
	AND	ref_tablekey = deleted.ord_hdrnumber
	AND	ref_number = deleted.fbc_refnumber

	--PTS28147 MBR 06/06/05
	IF NOT EXISTS(SELECT *
                        FROM freight_by_compartment, deleted
                       WHERE freight_by_compartment.fbc_refnumber = deleted.fbc_refnumber AND
                             freight_by_compartment.ord_hdrnumber = deleted.ord_hdrnumber AND
                             freight_by_compartment.fbc_id <> deleted.fbc_id)
	BEGIN
		-- delete the one edited
		DELETE referencenumber
		FROM deleted
		WHERE ref_tablekey = deleted.ord_hdrnumber
		AND	ref_table = 'orderheader'
		AND	ref_number = deleted.fbc_refnumber
		AND	ref_type = @reftype
		AND	ref_sequence = @seq
	END

	-- resequence remainig refnums
	UPDATE referencenumber 
	SET ref_sequence = ref_sequence - 1
	FROM deleted
	WHERE ref_table = 'orderheader'
	AND	ref_tablekey = deleted.ord_hdrnumber
	AND 	ref_sequence > @seq

	-- find the highest sequence
	SELECT @seq = MAX(ref_sequence) + 1
	FROM inserted, referencenumber
	WHERE ref_tablekey = inserted.ord_hdrnumber
	AND	ref_table = 'orderheader'
	IF @seq IS NULL
		SET @seq = 1	

	--PTS28147 MBR 06/06/05
	IF NOT EXISTS(SELECT *
                        FROM inserted, referencenumber
                       WHERE ref_tablekey = inserted.ord_hdrnumber AND
                             ref_type = @reftype AND
                             ref_table = 'orderheader' AND
                             ref_number = inserted.fbc_refnumber)
	BEGIN
		-- insert new one, but only if it is non blank
		INSERT INTO referencenumber (
			  ref_tablekey
			, ref_type	
			, ref_number
			, ref_sequence
			, ord_hdrnumber
			, ref_table )
		SELECT 
			  inserted.ord_hdrnumber
			, @reftype
			, inserted.fbc_refnumber
			, @seq
			, inserted.ord_hdrnumber
			, 'orderheader' 
		FROM inserted	
		WHERE inserted.fbc_refnumber > ''
	END

	-- ensure that the remaining refnums start w/ sequence of 1
	SELECT @seq = MIN(ref_sequence)
	FROM inserted, referencenumber
	WHERE ref_tablekey = inserted.ord_hdrnumber
	AND	ref_table = 'orderheader'

	IF @seq > 1
		UPDATE referencenumber
		SET ref_sequence = 1
		FROM inserted
		WHERE ref_tablekey = inserted.ord_hdrnumber
		AND	ref_table = 'orderheader'
		AND ref_sequence = @seq

	-- update orderheader to match first ref num
	IF EXISTS(SELECT * FROM referencenumber, inserted WHERE ref_table = 'orderheader' AND ref_tablekey = inserted.ord_hdrnumber)
		UPDATE orderheader
		SET  ord_refnum = ref_number
			, ord_reftype = ref_type
		FROM referencenumber, inserted
		WHERE ref_tablekey = inserted.ord_hdrnumber
		AND	ref_table = 'orderheader'
		AND	ref_sequence = 1
		AND 	orderheader.ord_hdrnumber = inserted.ord_hdrnumber
	ELSE
		UPDATE orderheader
		SET ord_refnum = ''
		FROM inserted
		WHERE inserted.ord_hdrnumber = orderheader.ord_hdrnumber

END
/********************************************
  UPDATE TANK DIP HISTORY
    On insert tag the dip history with the order number


*****************************************************/

 If (Select count(*) From compinvprofile,inserted
    Where compinvprofile.cmp_id = inserted.fbc_consignee) > 0
  BEGIN
     /* new fbc record where the tankdiphistory has not been updated with this ord# for this tank */
    If (Not Exists (Select * from deleted))
      And (Not Exists (Select * From tankdiphistory,inserted
         where tankdiphistory.ord_hdrnumber = inserted.ord_hdrnumber
         and tankdiphistory.tank_nbr = inserted.fbc_tank_nbr))
       UPDATE tankdiphistory 
       Set ord_hdrnumber = inserted.ord_hdrnumber
       From inserted
       Where tankdiphistory.tank_nbr = inserted.fbc_tank_nbr
       And   IsNull(tankdiphistory.ord_hdrnumber,0) = 0
       And tankdiphistory.tank_dip_date = 
           (Select Max(tank_dip_date) From tankdiphistory TDH2
            Where TDH2.tank_nbr = inserted.fbc_tank_nbr
            And IsNull(TDH2.ord_hdrnumber,0) = 0)
    /*  tank has changed on FBC, if tankdiphistory for this tank not yet set to ord# set it */
    If Update(fbc_tank_nbr) and (Select count(*) from deleted) > 0
      BEGIN
          If Not Exists (Select * From freight_by_compartment FBC  JOIN deleted DEL on 
                       FBC.ord_hdrnumber = DEL.ord_hdrnumber
                       Where FBC.fbc_tank_nbr = DEL.fbc_tank_nbr)
           UPDATE tankdiphistory
           Set ord_hdrnumber = 0
           From deleted DEL
           Where tankdiphistory.ord_hdrnumber = DEL.ord_hdrnumber
           And   tankdiphistory.tank_nbr = DEL.fbc_tank_nbr 
 
       Update tankdiphistory
       Set ord_hdrnumber = inserted.ord_hdrnumber
       From inserted
       Where tankdiphistory.tank_nbr = inserted.fbc_tank_nbr
       And tankdiphistory.tank_dip_date = 
           (Select max(tank_dip_date) from  tankdiphistory TDH2,deleted DEL
             Where TDH2.tank_nbr = DEL.fbc_tank_nbr
            And IsNull(TDH2.ord_hdrnumber,0) = DEL.ord_hdrnumber)

    
      END
/*    If Update(fbc_delivered)      
      If (Select fbc_delivered From inserted) = 'Y' 
        BEGIN
          -- allow the macro updating flag delivered to be run more than once 
          Select @VOL = Sum( Round(Convert(int,IsNull(freight_by_compartment.fbc_volume,0)),0))
          From freight_by_compartment,inserted
          Where freight_by_compartment.ord_hdrnumber = inserted.ord_hdrnumber
          And  freight_by_compartment.fbc_tank_nbr = inserted.fbc_tank_nbr 

         
          Update tankdiphistory
          Set tank_deliveredqty = @vol
          From inserted
          Where tankdiphistory.ord_hdrnumber = inserted.ord_hdrnumber
          And   tankdiphistory.tank_nbr = inserted.fbc_tank_nbr

       END
*/
 
  END
/* 33705 John Erik reports he wants to update delivered dips on the freight_by_compartment screen where no mobil comm */
/* following code adapted (moved) from tm_upd_freight_by_compartment */
/* 7/12/06 JEA says that delivered volume is gross volume not net, change code to use gross */
  Declare @v_lastdipdate datetime,@v_tanknbr int,@v_stparrivaldate datetime,@v_priordip int,@v_dipbefore int,@v_dipafter int
  Declare @v_modelid varchar(12),@v_priorvolume int,@v_dipvolume int,@v_sales int,@v_stpdeparture datetime
  Declare @v_volgross int,@v_stpnumber int
  if update(dip_after) and update (dip_before)
    BEGIN
/*
        Select @v_stpnumber=min(stops.stp_number),@v_stparrivaldate=min(stp_arrivaldate),
        @v_stpdeparture = min(stp_departuredate),@v_dipafter = min(dip_after),@v_dipbefore = min(dip_before)
        ,@v_tanknbr = min(fbc_tank_nbr), @v_volgross =  min(fbc_volume)
        from inserted
        join stops on inserted.stp_number = stops.stp_number
*/
        SELECT @v_stpnumber=fbc.stp_number,@v_stparrivaldate=min(stp_arrivaldate),
               @v_stpdeparture =min(stp_departuredate),@v_dipafter = min(inserted.dip_after),@v_dipbefore=min(inserted.dip_before)
               ,@v_tanknbr=fbc.fbc_tank_nbr,@v_volgross = SUM(fbc.fbc_volume)
        from inserted 
        join stops on inserted.stp_number = stops.stp_number
        INNER JOIN Freight_by_compartment FBC ON inserted.stp_number=fbc.stp_number AND fbc.fbc_tank_nbr = inserted.fbc_tank_nbr
        GROUP BY fbc.stp_number,fbc.fbc_tank_nbr

        Select @v_modelid = tank_model_id from tank Where tank_nbr = @v_tanknbr

        If @v_dipafter > 0 -- assume if dip after recorded, the dip before was also valid even if zero
           BEGIN
             -- get most recent  dip volume information (assumes dip come in sequentially and this one is later than the last recorded) 
             select @v_lastdipdate = max(dl_date) from diplog where tank_nbr = @v_tanknbr
             and dl_date < @v_stparrivaldate
             -- volume from diplog entry priod to these two entries (before and after) 
              --  note: dipcharts don't necessarily include all dip readings 
             If @v_lastdipdate is not null and 
                not exists (select 1 from diplog where tank_nbr = @v_tanknbr and dl_date = @v_stparrivaldate and dl_dipreading = @v_dipbefore)    
               BEGIN
                select @v_priordip =  dl_dipreading 
                from diplog where tank_nbr = @v_tanknbr and dl_date = @v_lastdipdate
                select @v_priorvolume = tank_volume from tankdipchart 
                 where model_id = @v_modelid and tank_dip =
                 (select Max(tank_dip) from tankdipchart tdc2 where tdc2.model_id = @v_modelid and tdc2.tank_dip <= 
                 (select max(dl_dipreading) from diplog where tank_nbr = @v_tanknbr and dl_date = @v_lastdipdate))
               -- before dip volume 
               Select @v_dipvolume = tank_volume from tankdipchart where  model_id = @v_modelid 
               and tank_dip = (select max(tank_dip) from tankdipchart tdc2 where tdc2.model_id = @v_modelid
               and tank_dip <= @v_dipbefore)
                -- sales on before dip is the difference prior volume - before dip volume
               select @v_sales = Case @v_priorvolume when 0 then 0 else (@v_priorvolume - @v_dipvolume) end
               Select @v_sales = Case when @v_sales < 0 then 0 else @v_sales end

               Insert into diplog (tank_nbr,dl_date,dl_dipreading,dl_source,dl_updatedby,dl_updatedon,dl_delivervolume,dl_salesvolume)
               Values (@v_tanknbr,@v_stparrivaldate,@v_dipbefore,'iutfbc',suser_sname(),getdate(),0,@v_sales)
               
               -- sales on after dip is prior dip volume + delivered volume - current dip volume 
               --select @v_priorvolume = @v_dipvolume
               --Select @v_dipvolume = tank_volume from tankdipchart where  model_id = @v_modelid 
               --and tank_dip = (select max(tank_dip) from tankdipchart tdc2 where tdc2.model_id = @v_modelid
               --and tank_dip <= @v_dipafter)
               --select @v_sales = @v_priorvolume + @v_volgross   - @v_dipvolume 

               Insert into diplog (tank_nbr,dl_date,dl_dipreading,dl_source,dl_updatedby,dl_updatedon,dl_delivervolume,dl_salesvolume)
               Values (@v_tanknbr,@v_stpdeparture,@v_dipafter,'iutfbc',suser_sname(),getdate(),@v_volgross,0) --@v_sales)

           END
      END -- there is data for this compartment
 END
GO
ALTER TABLE [dbo].[freight_by_compartment] ADD CONSTRAINT [pk_freight_by_compartment] PRIMARY KEY CLUSTERED ([fbc_id]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_freight_by_compartment_fbc_refnumber] ON [dbo].[freight_by_compartment] ([fbc_refnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fbc_tank_nbr] ON [dbo].[freight_by_compartment] ([fbc_tank_nbr]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_fgt_number] ON [dbo].[freight_by_compartment] ([fgt_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_mov_number] ON [dbo].[freight_by_compartment] ([mov_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_ord_hdrnumber] ON [dbo].[freight_by_compartment] ([ord_hdrnumber]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_stp_number] ON [dbo].[freight_by_compartment] ([stp_number]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_stp_number_load] ON [dbo].[freight_by_compartment] ([stp_number_load]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[freight_by_compartment] TO [public]
GO
GRANT INSERT ON  [dbo].[freight_by_compartment] TO [public]
GO
GRANT SELECT ON  [dbo].[freight_by_compartment] TO [public]
GO
GRANT UPDATE ON  [dbo].[freight_by_compartment] TO [public]
GO
