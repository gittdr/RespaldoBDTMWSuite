SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[cloneorderwithoptions]
		(@copies 				int
		,@ordnumber 			varchar(12)
		,@ordbookedby		 	varchar(20)
		,@copydates 			char(1)
		,@startdate		 		datetime
		,@incrementalDays 		int
		,@incrementalHours 		int
		,@incrementalMinutes	int
		,@copystatus 			char(1)
		,@status 				varchar(6)
		,@copyquantities 		char(1)
		,@copylinehaul 			char(1)
		,@copyAccessorials 		char(1)
		,@copynotes 			char(1)
		,@copydelinstructions 	char(1)
		,@copypaydetails 		char(1)
		,@copyordrefs 			char(1)
		,@copyotherrefs 		char(1)
		,@copyloadrequirements 	char(1)
		,@copyinvoicebackouts 	char(1)
		,@copyassigns 			char(1)
		,@asgndriver1 			varchar(8)
		,@asgndriver2 			varchar(8)
		,@asgntractor 			varchar(8)
		,@asgntrailer1 			varchar(13)
		,@asgntrailer2 			varchar(13)
		,@asgncarrier 			varchar(8)
		,@daysperweek 			smallint
		,@revtype1 				varchar(6)
		,@revtype1_format 		char(1)
		,@reserved 				varchar(254)
		,@UseAlphaOrdId			char(1) = 'N'
		,@copymasterinvstatus		char(1)
		,@copyextrainfo			char(1)
		,@copypermitrequirements	char(1)
         -- TGRIFFIT - PTS #38785 
        ,@copyreftype           varchar(50)
        ,@copyrefnum            varchar(30)
        -- END TGRIFFIT - PTS #38785
        -- TGRIFFIT - PTS #38783
         ,@availdtascurrdt       char(1)
        -- END TGRIFFIT - PTS #38783
         ,@OverrideBookedRevtype1 varchar(12)  -- 41629 recode Pauls
		,@copythirdparty 		char(1)	-- 44064
		,@includeorigord		char(1)		-- PTS 43913 - DJM
)
AS

/* Change Control

****** IF YOU ADD ARGUMENTS ALSO CHANGE
       d_ordercopies  
       cloneorderwithoptions_aggregate (sp)
       d_coloneorderwithoptions_aggregate (psdspsrv)
       itut_jws_import_order_weights  (calls colneorder..aggregate)  
************

01/28/2005	KWS	PTS #22785 Moved logic to cloneorderwithoptions_aggregate
06/30/2005	JJF 	PTS 28538 Added @copypermitrequirements + passthrough to next cloneorderwithoptions_aggregate
09/21/2007  TGRIFFIT PTS #38785 Added @copyreftype,@copyrefnum + passthrough to cloneorderwithoptions_aggregate
09/24/2007  TGRIFFIT PTS #38783 Added @availdtascurrdt + passthrough to cloneorderwithoptions_aggregate
03/19/08    DPETE PTS41629 add overrideBookdeRevtype1 value to override order value with user value
08/21/2008  JSwindell PTS44064 Added @copythirdparty + passthrough to cloneorderwithoptions_aggregate
08/12/08	DJM		43913 - Add parameter to tell the proc to include the 'original' order in the results of the Copied orders
*/
EXEC cloneorderwithoptions_aggregate @copies, @ordnumber, @ordbookedby, @copydates, @startdate, 
									 @incrementalDays, @incrementalHours, @incrementalMinutes,
									 @copystatus, @status, @copyquantities, @copylinehaul,
									 @copyAccessorials, @copynotes, @copydelinstructions, @copypaydetails,
									 @copyordrefs, @copyotherrefs, @copyloadrequirements, @copyinvoicebackouts,
									 @copyassigns, @asgndriver1, @asgndriver2, @asgntractor, @asgntrailer1,
									 @asgntrailer2, @asgncarrier, @daysperweek, @revtype1, @revtype1_format,
									 @reserved, @UseAlphaOrdId, @copymasterinvstatus, @copyextrainfo, -1, 
                                     @copypermitrequirements, @copyreftype, @copyrefnum, @availdtascurrdt,
									 @OverrideBookedRevtype1, @copythirdparty ,@includeorigord
GO
GRANT EXECUTE ON  [dbo].[cloneorderwithoptions] TO [public]
GO
