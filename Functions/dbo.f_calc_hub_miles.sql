SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[f_calc_hub_miles] (@mov_number int)
RETURNS int
AS
begin

   /*
   THIS FUNCTION MIMICS f_populate_prev_hub and f_calc_hub_miles and returns the hub miles for a move
   it does not have the LEG/MOVE option and will always calculate by MOVE
   it does not do EMPTY vs. Loaded
   */

   DECLARE
   @Sequence         int,
   @NextSequence     int,
   @prev_tractor     varchar(8),
   @prev_hubmiles    int,
   @evt_tractor      varchar(8),
   @evt_hubmiles     int,
   @minsequence      int,
   @max_prev_hubmiles   int,
   @current_lgh_number int,
   @prev_lgh_number  int,
   @result           int,
   @index            int



   --select mov_number from invoiceheader where ord_hdrnumber = 3785
   --select @mov_number = 4384

   DECLARE @stops TABLE(
   evt_driver1       varchar(8)
   ,evt_tractor      varchar(8)
   ,evt_trailer1     varchar(13)
   ,ord_hdrnumber    int
   ,stp_number       int
   ,stp_city         int
   ,evt_startdate    datetime
   ,cmp_id           varchar(8)
   ,cmp_name         varchar(30)
   ,evt_enddate      datetime
   ,lgh_number       int
   ,stp_sequence     int
   ,evt_hubmiles     int
   ,evt_carrier      varchar(8)
   ,evt_sequence     int
   ,stp_mfh_sequence int
   ,fgt_sequence     smallint
   ,fgt_number       int
   ,ord_billto       varchar(8)
   ,evt_number       int
   ,evt_pu_dr        varchar(6)
   ,evt_eventcode    varchar(6)
   ,evt_status       varchar(6)
   ,stp_mfh_mileage  int
   ,stp_ord_mileage  int
   ,stp_lgh_mileage  int
   ,mfh_number       int
   ,billto_name      varchar(100)   --PTS 71170 SPN changed from varchar(30) to varchar(100)
   ,cty_nmstct       varchar(30)
   ,mov_number       int
   ,stp_region1      varchar(6)
   ,stp_state        varchar(6)
   ,skip_trigger     smallint
   ,stp_zipcode      varchar(10)
   ,stp_address      varchar(40)
   ,billable_flag    varchar(1)
   ,stp_departure_status varchar(6)
   ,cht_itemcode     varchar(6)
   ,cht_basisunit    varchar(6)
   ,trc_currenthub      int
   ,prev_hub         int
   ,evt_hubmiles_calc  int
   ,stp_loadstatus      varchar(6)
   ,stp_trip_mileage int

   )

   DECLARE  @Tractor_result table
   (
   trc_result  int,
   row         int
   )



   INSERT INTO @stops
   select   e.evt_driver1
        ,e.evt_tractor
        ,e.evt_trailer1
        ,s.ord_hdrnumber
        ,s.stp_number
        ,s.stp_city
        ,e.evt_startdate
        ,s.cmp_id
        ,s.cmp_name
        ,e.evt_enddate
        ,s.lgh_number
        ,s.stp_sequence
        ,e.evt_hubmiles
        ,e.evt_carrier
        ,e.evt_sequence
        ,s.stp_mfh_sequence
        ,fd.fgt_sequence
        ,fd.fgt_number
        ,oh.ord_billto
        ,e.evt_number
        ,e.evt_pu_dr
        ,e.evt_eventcode
        ,e.evt_status
        ,s.stp_mfh_mileage
        ,s.stp_ord_mileage
        ,s.stp_lgh_mileage
        ,s.mfh_number
      ,(select co.cmp_name from company co where co.cmp_id = oh.ord_billto) as billto_name
      ,c.cty_nmstct cty_nmstct
      ,s.mov_number
      ,s.stp_region1
        ,s.stp_state
        ,1 as skip_trigger
        ,s.stp_zipcode
        ,s.stp_address
      ,isnull(sign(abs(s.ord_hdrnumber)), 0) as billable_flag
      ,s.stp_departure_status
        ,fd.cht_itemcode
        ,fd.cht_basisunit
      ,tp.trc_currenthub
      ,0 as prev_hub
      ,e.evt_hubmiles as evt_hubmiles_calc
      ,s.stp_loadstatus
      ,s.stp_trip_mileage
  from   freightdetail fd  RIGHT OUTER JOIN  stops s  ON  fd.stp_number  = s.stp_number
         LEFT OUTER JOIN  orderheader oh  ON  oh.ord_hdrnumber  = s.ord_hdrnumber
         LEFT OUTER JOIN  city c  ON  c.cty_code  = s.stp_city ,
      tractorprofile tp  RIGHT OUTER JOIN  event e  ON  tp.trc_number  = e.evt_tractor

  where
   e.stp_number = s.stp_number
   and   e.evt_sequence = 1
   and s.mov_number = @mov_number

   /*
   --DEBUG
   select * from @stops
   order by stp_mfh_sequence
   */

   -- POPULATE PREVIOUS HUB MILES
   Select @Sequence = (Select MAX(stp_mfh_sequence) from @stops)
   Select @NextSequence = (Select MIN(stp_mfh_sequence) from @stops)
   Select @minsequence = (Select MIN(stp_mfh_sequence) from @stops)

   select @prev_tractor = ''
   select @prev_hubmiles = 0

   While @Sequence >= @NextSequence
      BEGIN
         Select @evt_tractor = isnull(evt_tractor,'') from @stops where stp_mfh_sequence = @NextSequence
         Select @evt_hubmiles = isnull(evt_hubmiles,0) from @stops where stp_mfh_sequence = @NextSequence

         IF (@evt_tractor = @prev_tractor) or ((@sequence = @minsequence) AND ( @prev_tractor = '' or @evt_tractor = '' ))
            BEGIN
               IF @evt_hubmiles = 0
               BEGIN
                  Select @evt_hubmiles = @prev_hubmiles
                  update @stops
                  set evt_hubmiles = @evt_hubmiles
                  where stp_mfh_sequence = @NextSequence
               END
               IF @prev_hubmiles = 0
               BEGIN
                  Select @prev_hubmiles = @evt_hubmiles
               END

               update @stops
               set prev_hub = @prev_hubmiles
               where stp_mfh_sequence = @NextSequence
            END
         ELSE
            BEGIN
               select @max_prev_hubmiles = 0
               update @stops
               set prev_hub = @evt_hubmiles
               where stp_mfh_sequence = @NextSequence
            END



         Select @NextSequence = (Select MIN(stp_mfh_sequence)
                           from @stops
                           where stp_mfh_sequence > @NextSequence)

         Select @prev_tractor = @evt_tractor
         select @prev_hubmiles = @evt_hubmiles
         IF @evt_hubmiles >   @max_prev_hubmiles
            BEGIN
               Select @max_prev_hubmiles = @evt_hubmiles
            END


   END

   -- CALCULATE HUB MILES
   Select @Sequence = (Select MAX(stp_mfh_sequence) from @stops)
   Select @NextSequence = (Select MIN(stp_mfh_sequence) from @stops)
   Select @minsequence = (Select MIN(stp_mfh_sequence) from @stops)

   select @prev_tractor = ''
   select @prev_hubmiles = 0
   select @index = 0
   select @result = 0



   While @Sequence >= @NextSequence
      BEGIN
         Select @current_lgh_number = isnull(lgh_number,0) from @stops where stp_mfh_sequence = @NextSequence
         Select @evt_hubmiles = isnull(evt_hubmiles,0) from @stops where stp_mfh_sequence = @NextSequence
         Select @prev_hubmiles = isnull(prev_hub,0) from @stops where stp_mfh_sequence = @NextSequence
         Select @evt_tractor = isnull(evt_tractor,'') from @stops where stp_mfh_sequence = @NextSequence
         /*
         --DEBUG
         SELECT @evt_tractor,@prev_tractor, @NextSequence, @minsequence
         */

         IF (@evt_tractor <> @prev_tractor) AND (@evt_tractor <> '') AND (@prev_tractor <> '')
            BEGIN
               IF @NextSequence > @minsequence
               BEGIN

                  --BEGIN PTS 60159 SPN
                  --select @index += 1
                  select @index = @index + 1
                  --END PTS 60159 SPN
                  insert into @Tractor_result
                  (trc_result,row)
                  VALUES
                  (@result,@index)
               END
               Select @result = 0
            END

         IF @prev_lgh_number = @current_lgh_number
            BEGIN
               --BEGIN PTS 60159 SPN
               --select @result += @evt_hubmiles - @prev_hubmiles
               select @result = @result + (@evt_hubmiles - @prev_hubmiles)
               --END PTS 60159 SPN
            END

         Select @NextSequence = (Select MIN(stp_mfh_sequence)
                           from @stops
                           where stp_mfh_sequence > @NextSequence)

         Select @prev_tractor = @evt_tractor
         select @prev_lgh_number = @current_lgh_number
   END


   /*
   --DEBUG
   select prev_hub, evt_hubmiles,* from @stops
   order by stp_mfh_sequence
   select * from @Tractor_result
   */

   --BEGIN PTS 60159 SPN
   --select @result += isnull(sum(isnull(trc_result,0)),0) from @Tractor_result
   select @result = @result + isnull(sum(isnull(trc_result,0)),0) from @Tractor_result
   --END PTS 60159 SPN
   RETURN @result



END

GO
GRANT EXECUTE ON  [dbo].[f_calc_hub_miles] TO [public]
GO
