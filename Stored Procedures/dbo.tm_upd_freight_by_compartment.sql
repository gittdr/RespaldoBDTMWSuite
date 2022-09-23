SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE  PROCEDURE [dbo].[tm_upd_freight_by_compartment] @stp_num_load_in varchar(15) = null,
						     @stp_num_unload_in varchar(15) = null,
						     @cpt_in varchar(15) = null, 
						     @manifest varchar(50) = null,
						     @vol_gross_in varchar(15) = null,
						     @vol_net_in varchar(15) = null,
						     @tank_num_in varchar(15) = null,
						     @dip_before_in varchar(15) = null,
						     @dip_after_in varchar(15) = null,
						     @weight_in varchar(15) = null
AS


/**
 * NAME:
 * tm_upd_freight_by_compartment
 * 
 * TYPE:
 * StoredProcedure
 * 
 * DESCRIPTION:
 * Update freight by compartment and record dip log frompickup or delivery stop
 * 
 * RETURN:
 * None.
 * 
 * RESULT SETS:
 * None
 *
 * PARAMETERS: (old proc parms)
 * @stp_num_load_in varchar(15) = null,
 * @stp_num_unload_in varchar(15) = null,
 * @cpt_in varchar(15) = null, 
 * @manifest varchar(50) = null,
 * @vol_gross_in varchar(15) = null,
 * @vol_net_in varchar(15) = null,
 * @tank_num_in varchar(15) = null,
 * @dip_before_in varchar(15) = null,
 * @dip_after_in varchar(15) = null,
 * @weight_in varchar(15) = null
 * 
 * REFERENCES: (called by and calling references only, don't include table/view/object references)
 * Calls001    – NONE
 * CalledBy001 – NONE
 *
 * For each order at each stop  8 calls are made. One each for compartments 1-8 whether or
 * not they exist on the trailer or if they were used by this order. The extra calls have stop
 * number and comartment only, all other arguments are ''. They are in compartment # sequence.
 * For load stop calls the manifest number is typically only on the frist compartment where
 * product is loaded, any other loaded comaprtment calls in the set do not have a manifest number.
 *
 * REVISION HISTORY:
 * 07/01/2005 .01 - PTS???? - Vadim Volisov - Initial release.
 * 08/30/05   .02 - PTS29618 DPETE write to diplog and a bit of clean up
 * 10/06/05   .03 - PTS 30103 DPETE trauck reports back total loaded for all compartments as one message
 *                  need to process the zero quantity messages to clear out the planned loading quantities
 *                  for other compartents
 * 4/12/06    .04 - PTS32542 record volume delivered and sales volume in dip log
 * 7/12/06    .05 - PTS33705 Want to add diplog records when adding dips on freight _by_compartment. Move code to iut_fbc
 * 8/23/07          TS 39099 DPETE weight is being set to zero on the freight by compartment table
 **/

SET NOCOUNT ON 

DECLARE @stp_num_load int,
	 @stp_num_unload int,
	 @cpt int,
	 @tank_num int,
	 @vol_gross float(8),
	 @vol_net float(8),
	 @dip_before int,
	 @dip_after int,
	 @weight float(8),
	 @cmp_id varchar(25) --PTS 61189 CMP_ID INCREASE LENGTH TO 25
         ,@v_cmd varchar(8)
         ,@v_tanknbr int
         ,@v_stparrival datetime
         ,@v_stpdeparture datetime
         ,@v_modelid varchar(12)
         ,@v_lastdipdate datetime
         ,@v_sales int
         ,@v_priorvolume int
         ,@v_dipvolume int
         ,@v_priordip int


SELECT @stp_num_load = convert(int, isnull(@stp_num_load_in,'0'))
SELECT @stp_num_unload = convert(int, isnull(@stp_num_unload_in,'0'))
SELECT @cpt = convert(int, isnull(@cpt_in,'0'))
SELECT @tank_num = convert(int, isnull(@tank_num_in,'0'))
SELECT @vol_gross = convert(float(8), isnull(@vol_gross_in,'0.00'))
SELECT @vol_net = convert(float(8), isnull(@vol_net_in,'0.00'))
SELECT @dip_before = convert(int, isnull(@dip_before_in,'0'))
SELECT @dip_after = convert(int, isnull(@dip_after_in,'0'))
SELECT @weight = convert(float(8), isnull(@weight_in,'0.00'))


IF @stp_num_load>0 
BEGIN  -- process load
   --If @manifest > '' or @vol_gross_in > '' or @vol_net_in > '' or @weight_in > ''
   --   BEGIN  -- there is data for this compartment in the call

	-- if no manifest, check to see if one exists on another fbc row for the same stop and tank number
	IF ISNULL(@manifest,'')=''
          BEGIN
		SELECT @manifest=MAX(IsNull(fbc_refnumber,''))
		FROM freight_by_compartment (NOLOCK)
		WHERE stp_number_load=@stp_num_load /*AND fbc_compartm_number = @cpt - 1*/
          END

	UPDATE freight_by_compartment SET
		fbc_refnumber=UPPER(IsNull(@manifest,'')),
		fbc_volume=@vol_gross,
		fbc_net_volume=@vol_net,
		--fbc_weight=@weight
        fbc_weight= 
         case @weight 
           when 0 then case @vol_gross when 0 then fbc_weight else round(@vol_gross * cpr_density,0) end
           else @weight
           end
	 WHERE stp_number_load=@stp_num_load
	   AND fbc_compartm_number=@cpt


     -- END  -- there is data for this compartment in the call
END  -- process load 
ELSE
IF @stp_num_unload>0 
BEGIN  -- process unload
/*
	-- replicate manifest from previous compartment (DPETE trace indicates unload never update manifest)
	IF ISNULL(@manifest,'')=''
		SELECT @manifest=fbc_refnumber FROM freight_by_compartment WHERE stp_number=@stp_num_unload AND fbc_compartm_number = @cpt - 1

	-- if manifest left blank, preserve the one entered on load
	IF NOT ISNULL(@manifest,'')=''
		UPDATE freight_by_compartment SET 
			fbc_refnumber=@manifest
		 WHERE stp_number=@stp_num_unload
		   AND fbc_compartm_number=@cpt --AND ISNULL(fbc_refnumber,'')=''

	-- if unload weight is entered, overwrite load weight 
	IF ISNULL(@weight,0)>0
		UPDATE freight_by_compartment SET 
			fbc_weight=@weight
		 WHERE stp_number=@stp_num_unload
		   AND fbc_compartm_number=@cpt --AND ISNULL(fbc_weight,0)=0
*/
--   If @tank_num > '' or @dip_before_in > '' or @dip_after_in > '' or @weight_in > ''
--      BEGIN  -- there is data for this compartment in the call
    SELECT @cmp_id = cmp_id, @v_stparrival = stp_arrivaldate, 
               @v_stpdeparture = Case stp_departuredate When stp_arrivaldate Then Dateadd(mi,1,stp_departuredate)Else stp_departuredate End 
    From stops (NOLOCK)
    Where stp_number = @stp_num_unload

    SELECT @v_tanknbr = tank_nbr,@v_modelid = tank_model_id 
    from tank (NOLOCK)
    Where cmp_id = @cmp_id and tank.tank_loc = @tank_num


	UPDATE freight_by_compartment SET 
	  fbc_delivered='Y',
          tank_loc = @tank_num,
	  fbc_tank_nbr = @v_tanknbr,
	  dip_before = @dip_before,
	  dip_after = @dip_after
          --,fbc_refnumber = Case Rtrim(UPPER(IsNull(@manifest,''))) When '' Then fbc_refnumber else @manifest End
          ,fbc_weight = Case IsNull(@weight,0) When 0 Then fbc_weight Else @weight End 
	 WHERE stp_number = @stp_num_unload
	 AND fbc_compartm_number=@cpt
/*
         If @dip_after > 0 -- assume if dip after recorded, the dip before was also valid even if zero
           BEGIN
             -- get prior dip volume information 
             SELECT @v_lastdipdate = max(dl_date) from diplog where tank_nbr = @v_tanknbr
             -- volume from diplog entry priod to these two entries (before and after) 
                note: dipcharts don't necessarily include all dip readings 
             If @v_lastdipdate is not null and 
                not exists (SELECT 1 from diplog where tank_nbr = @v_tanknbr and dl_date = @v_stparrival and dl_dipreading = @dip_before
                  and dl_source = 'TM' )
               BEGIN
                SELECT @v_priordip =  dl_dipreading 
                from diplog where tank_nbr = @v_tanknbr and dl_date = @v_lastdipdate
                SELECT @v_priorvolume = tank_volume from tankdipchart 
                 where model_id = @v_modelid and tank_dip =
                 (SELECT Max(tank_dip) from tankdipchart tdc2 where tdc2.model_id = @v_modelid and tdc2.tank_dip <= 
                 (SELECT max(dl_dipreading) from diplog where tank_nbr = @v_tanknbr and dl_date = @v_lastdipdate))
               -- before dip volume 
               SELECT @v_dipvolume = tank_volume from tankdipchart where  model_id = @v_modelid 
               and tank_dip = (SELECT max(tank_dip) from tankdipchart tdc2 where tdc2.model_id = @v_modelid
               and tank_dip <= @dip_before)
                -- sales on before dip is the difference prior volume - before dip volume
               SELECT @v_sales = Case @v_priorvolume when 0 then 0 else (@v_priorvolume - @v_dipvolume) end
               SELECT @v_sales = Case when @v_sales < 0 then 0 else @v_sales end

               Insert into diplog (tank_nbr,dl_date,dl_dipreading,dl_source,dl_updatedby,dl_updatedon,dl_delivervolume,dl_salesvolume)
               Values (@v_tanknbr,@v_stparrival,@dip_before,'TM','sa',getdate(),0,@v_sales)

               -- sales on after dip is prior dip volume + delivered volume - current dip volume 
               SELECT @v_priorvolume = @v_dipvolume
               SELECT @v_dipvolume = tank_volume from tankdipchart where  model_id = @v_modelid 
               and tank_dip = (SELECT max(tank_dip) from tankdipchart tdc2 where tdc2.model_id = @v_modelid
               and tank_dip <= @dip_after)
               SELECT @v_sales = @v_priorvolume + @vol_net   - @v_dipvolume 

               Insert into diplog (tank_nbr,dl_date,dl_dipreading,dl_source,dl_updatedby,dl_updatedon,dl_delivervolume,dl_salesvolume)
               Values (@v_tanknbr,@v_stpdeparture,@dip_after,'TM','sa',getdate(),@vol_net,@v_sales)

           END
           
      END -- there is data for this compartment
   */

 END -- process unload


GO
GRANT EXECUTE ON  [dbo].[tm_upd_freight_by_compartment] TO [public]
GO
