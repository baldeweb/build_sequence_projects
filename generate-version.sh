#!/bin/bash

environmentCode=""
countryName=""
countryCode=""
projPath=""

listCountries=(
    "name=Argentina#code=Ar"
    "name=Bolivia#code=Bo"
    "name=Brasil#code=Br"
    "name=Canada#code=Ca"
    "name=Colombia#code=Co"
    "name=Dominican Republic#code=Do"
    "name=Ecuador#code=Ec"
    "name=El Salvador#code=Sv"
    "name=Great Britain#code=Gb"
    "name=Global#code=Global"
    "name=Honduras#code=Hn"
    "name=Mexico#code=Mx"
    "name=South Africa#code=Za"
    "name=South Korea#code=Kr"
    "name=Panama#code=Pa"
    "name=Paraguay#code=Py"
    "name=Peru#code=Pe"
    "name=United States#code=Us"
    "name=Uruguay#code=Uy"
)

listEnvironments=(
    "name=QA#code=Qa"
    "name=SIT#code=Sit"
)

listProjectName=(
    "access-management-android/accessmanagement-iam"
    "b2b-mobile-android-cart/cart"
    "b2b-mobile-android-checkout/checkout"
    "b2b-mobile-android-tickets"
    "b2b-mobile-android-truck/truck"
    "b2b-tapwiser-browse-android/browse"
    "b2b-tapwiser-order-history-android/order_tracking"
    "b2b-tapwiser-rating-android/rating"
    "bees-account-info-android"
    "bees-account-selection-android"
    "account-android"
    "bees-android/bees-actions"
    "bees-browse-android"
    "bees-cart-checkout-android"
    "bees-cart-checkout-commons-android/cartcheckout-commons"
    "bees-coupons-android/bees-coupons"
    "bees-customer-services-android/customer_services"
    "bees-datasource-android/bees-datasource"
    "bees-rio-android"
    "bees-search-commons-android/search-commons"
    "bees-shopex-commons-android/shopex-commons"
    "bees-social-android/bees-social-media"
    "credit-android/credit"
    "deliver-access-control-android/features/access-control"
    "deliver-analytics-android/features/analytics"
    "deliver-android"
    "deliver-inventory-validation-android/features/inventory"
    "deliver-pix-android"
    "deliver-pricing-engine-android"
    "deliver-questionnaire-android"
    "deliver-route-optimizer-android"
    "deliver-sdk-android"
    "deliver-tour-android/features/tour"
    "fintech-wallet-onboarding-android/wallet-onboarding"
    "insights-android/insights"
    "invoice-android/invoice"
    "payment-android/payment"
    "payment-selection-android/paymentselection"
    "recommender-android/beerrecommender"
    "rewards-android/rewards"
    "server-driven-ui-orchestrator-android/sd-ui-orchestrator"
    "tapwiser-android"
)

listProjectChosen=()

#   Project Versions Ref
orchestratorRef="orchestratorVersion"

#   Paths | Patterns
rootPathApkGenerated="/home/wallace/Documents/bees-android/app/build/outputs/apk/"
patternImplementationProject="implementation [\"']com\.abinbev.*[.:][^:\"']*:[^:\"']*['\"]"

#   Projects with sub folders
sampleGradlePath="/sample-app"
appGradlePath="/app"

accountOrchestratorGradlePath="/features/orchestrator"

b2bMobileTicketsBeesAdapterGradlePath="/bees-adapter"
b2bMobileTicketsCrsGradlePath="/crs"

beesAccountInfoGradlePath="/account-info"
beesAccountSelectionGradlePath="/account-selection"

beesRioGradlePath="/rio"

deliverAccessControlGradlePath="/features/access-control"
deliverAnalyticsGradlePath="/features/analytics"
deliverInventoryValidationGradlePath="/features/inventory"
deliverPixGradlePath="/features/pix"
deliverPricingEngineGradlePath="/features/pricing-engine"
deliverQuestionnaireGradlePath="/features/questionnaire"
deliverRouteOptimizerGradlePath="/features/route-optimizer"
deliverSdkNetworkGradlePath="/sdk-network"
deliverTourGradlePath="/features/tour"

tapwiserAndroidFuzzNetworkGradlePath="/FuzzNetwork"
tapwiserAndroidFuzzParserGradlePath="/FuzzParser"
tapwiserAndroidFuzzReflectionGradlePath="/FuzzReflection"
tapwiserAndroidFuzzVolleyExecutorGradlePath="/FuzzVolleyExecutor"
tapwiserAndroidLifeCycleGradlePath="/Libraries/LifeCycle"
tapwiserAndroidSdkGradlePath="/surveymonkey_android_sdk"

#   Functions
function get_build_gradle_subfolder_path {
    projName=$1
    if [[ $projName == *"/"* ]]; then
        name=$(echo $projName | cut -d '/' -f2)
        echo "/$name"
    else
        echo ""
    fi
}

function get_project_name {
    projName=$1
    if [[ $projName == *"/"* ]]; then
        name=$(echo $projName | cut -d '/' -f1)
        echo $name
    else
        echo $projName
    fi
}

function to_lowercase {
    lowercase=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    echo $lowercase
}

function first_letter_uppercase {
    lowercase=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    word=$(echo "$lowercase" | sed 's/^\(.\)/\U\1/')
    echo $word
}

function get_country_code {
    optionTyped=""
    countryCode=""

    for countryName in "${!kvCountry[@]}"; do
        if [ $countryName = "$optionTyped" ]; then
            countryCode=${kvCountry[$countryName]}
        fi
    done

    echo $(first_letter_uppercase $countryCode)
}

function run_adb_install {
    countryName=$(echo "$countryName" | tr '[:upper:]' '[:lower:]')
    countryCode=$(echo "$countryCode" | tr '[:upper:]' '[:lower:]')
    environmentCode=$(echo "$environmentCode" | tr '[:upper:]' '[:lower:]')
    apkPath="$rootPathApkGenerated$countryCode/$environmentCode/app-$countryCode-$environmentCode.apk"
    appPackageName="com.abinbev.android.tapwiser.bees"

    countryCode=$(to_lowercase $countryCode)
    countryName=$(first_letter_uppercase $countryName)

    ./gradlew -Dorg.gradle.jvmargs=-Xmx1536m -XX:MaxPermSize=3072m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8-
    ./gradlew clean
    ./gradlew :app:assemble$countryCode$environmentCode
    
    adb install "$apkPath"

    clear
    show_bees_banner

    echo -e "\e[1m\e[33mPROCESS COMPLETED WITH TOTAL SUCCESS! BzZzzZzzz...\e[0m"
    echo -e "\e[3m(A bug free version... I hope...)\e[0m\n"
    echo -e "\e[1mNow, open your app manually and enjoy it! \(^^)/ \e[0m\n"

    exit 0
}

function create_menu_build_apk {
    local countryCodeRes=""
    local envCodeRes=""

    # Country
    clear
    show_countries
    echo -n -e "\n\e[33m> Type an option: \e[0m"
    read countryChosen

    countryCodeRes=$(get_country_code_by_option $countryChosen)
    countryNameRes=$(get_country_name_by_option $countryChosen)

    # Environments
    show_environments
    echo -n -e "\n\e[33m> Type an option: \e[0m"
    read envChosen
    envCodeRes=$(get_environment_code_by_option $envChosen)
    
    countryName="$countryNameRes"
    countryCode="$countryCodeRes"
    environmentCode="$envCodeRes"
}

function show_environments {
    echo -e "\n\n\e[1mENVIRONMENT LIST\e[0m"
    index=0
    for item in "${listEnvironments[@]}"
    do
        index=$(($index+1))
        name=$(extract_name $item)
        echo "[$index] $name"
    done
}

function show_countries {
    echo -e "\n\e[1mCOUNTRY LIST\e[0m"

    index=0
    for item in "${listCountries[@]}"
    do
        index=$(($index+1))
        name=$(extract_name $item)
        echo "[$index] $name"
    done
}

function get_environment_code_by_option {
    optionChosen=$1
    code=""

    index=0
    for item in "${listEnvironments[@]}"
    do
        index=$(($index+1))
        if [ $optionChosen = $index ]; then
            code=$(extract_code $item)
        fi
    done

    echo $code
}

function get_country_name_by_option {
    local optionChosen=$1
    local name=""

    local index=0
    for item in "${listCountries[@]}"
    do
        index=$(($index+1))
        if [ $optionChosen = $index ]; then
            name=$(extract_name $item)
        fi
    done

    echo $name
}

function get_country_code_by_option {
    local optionChosen=$1
    local code=""

    local index=0
    for item in "${listCountries[@]}"
    do
        index=$(($index+1))
        if [ $optionChosen = $index ]; then
            code=$(extract_code $item)
        fi
    done

    echo $code
}

function extract_code {
    local input="$1"
    local code=$(echo "$input" | grep -oP "(?<=#code=).*")
    echo "$code"
}

function extract_name {
    local text=$1
    local name=$(echo $text | grep -oP '(?<=name=)[^#]+')
    echo $name
}

function get_dependency_name {
    echo "$1" | sed -e 's/Version.*//' -e 's/.* //'
}

function run_gradle {
    local path=$1
    local modulePath=$2
    local name=$3
    
    clear
    echo -e "\e[1m\e[32m########## RUNNING: [$name] ##########\e[0m"

    cd "$path"
    ./gradlew prepareKotlinBuildScriptModel compileDebugKotlin sync

    case "$name" in
        "bees-android")
            ./gradlew clean
            ;;
        "account-android")
            moduleName=$(basename "$modulePath$OrchestratorGradlePath")
            ./gradlew :orchestrator:clean :orchestrator:build -Dorg.gradle.jvmargs=-Xmx1536m -XX:MaxPermSize=3072m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8- :orchestrator:assemble :orchestrator:publishToMavenLocal
            ;;
        *)
            moduleName=$(basename "$modulePath")
            ./gradlew ":$moduleName:clean" ":$moduleName:build" -Dorg.gradle.jvmargs=-Xmx1536m -XX:MaxPermSize=3072m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8 build ":$moduleName:assemble" ":$moduleName:publishToMavenLocal"
            ;;
    esac
}

function run_specs {
    pathSpecs=$1
    projectName=$2
    specsBranchName=""

    clear
    echo -e "\e[1mModifying: $projectName\e[0m"
    echo -n -e "\e[33m> Branch target for [sdk-android-specs](or just press ENTER to choose 'master'): \e[0m"
    read specsBranchName

    if [ -z "$specsBranchName" ]; then
        specsBranchName="master"
        echo -e "\e[32mBranch 'master' chosen.\e[0m"
    else
        echo -e "\e[32mBranch $specsBranchName chosen.\e[0m"
    fi
    echo -e "\n\e[3mPlease wait... Running specs routines...\e[0m\n"

    cd "$pathSpecs"
    git fetch
    git checkout $specsBranchName
    git reset --hard origin/$specsBranchName
    cd ..

    echo -e "\e[1m\e[32mSpecs Routines: Success ✓\e[0m\n"
}

function change_dependency_version {
    local gradleFilePath="$1/build.gradle"
    local dependencyRef=$2
    local name=$(get_dependency_name $dependencyRef)

    echo -n -e "\e[33m> dependency version of [${name#*/}](or just press ENTER to skip): \e[0m"
    read newVersion

    local currentLine="def $dependencyRef = \".*\""
    local newLine="def $dependencyRef = \"$newVersion\""

    lineFound=$(grep -n "^$currentLine" "$gradleFilePath" | cut -d ":" -f1)
    fileChanged=$(sed -i "${lineFound}s/$currentLine/$newLine/g" "$gradleFilePath")

    if $fileChanged; then
        true
    else
        echo -e "\e[33mSomething went wrong updating dependency $name.\nPlease, open the file manually, check and try again. \e[0m"
        exit 1
    fi
}

function menu_change_implementation_version {
    local gradleFilePath="$1/build.gradle"

    echo -e "\n\e[1mImplementation List\e[0m"

    i=0
    while read -r line; do
        ((i++))
        lineFormatted=$(echo "$line" | sed 's/^[[:space:]]*//')
        echo "[$i] $lineFormatted"
        linesArray[$i]="$lineFormatted"
    done < <(grep -E "$patternImplementationProject" "$gradleFilePath")

    if [ $i -eq 0 ]; then
        echo -e "\e[33mNo occurrences found.\nIgnore if this project needs no changes, or open and edit it manually.\e[0m"
    else
        echo -n -e "\n\e[33m> choose an option(or just press ENTER to skip): \e[0m"
        read implementationOption

        if [ -n "$implementationOption" ]; then
            echo -n -e "\n\e[33m> new implementation version(or just press ENTER to skip): \e[0m"
            read newVersion

            for ((i = 1; i <= ${#linesArray[@]}; i++)); do
                if [ $implementationOption = $i ]; then
                    line=${linesArray[$i]}
                    lineBeforeColon="${line%:*}:"
                    prefix=$(echo "$lineBeforeColon" | grep -o "*['\"].*com")
                    result=$(echo "$prefix$lineBeforeColon$newVersion\"" | sed "s/'/\"/g")
                    sed -i "s/$line/$result/g" "$gradleFilePath"
                fi
            done
        else
            echo -e "\e[33mNothing to update here. Moving next.\e[0m"
        fi
    fi
}

function change_version_ext_block {
    local fileFullPath="$1/build.gradle"

    isBlockstart=false
    isBlockend=false

    # read each line of the file
    while IFS= read -r line; do
        # Checks if it found the start of the code block
        if [[ $line == *"ext "*{ ]]; then
            isBlockstart=true
            continue
        fi

        # Checks if it found the end of the code block
        if [[ $line == *}* ]] && $isBlockstart; then
            isBlockend=true
        fi

        # Displays the lines within the code block
        if $isBlockstart && ! $isBlockend; then
            if [[ $line =~ .*Version\ *=\ *\".*\" ]]; then
                name=$(echo "$line" | awk -F '=' '{print $1}')

                echo -n -e "\e[33m> new version for [$name](or just press ENTER to skip): \e[0m"
                read newVersion

                if [ -z "$newVersion" ]; then
                    echo -e "\e[33mVersion not updated. Keeping the current version.\e[0m\n"
                else
                    lineChanged=$(echo "$line" | sed "s/\".*\"/\"$newVersion\"/")
                fi
            fi
        fi

    done < "$fileFullPath"
}

function change_version_properties {
    local projectFullPath=$1

    echo -n -e "\e[33m> new version for [$name](or just press ENTER to skip): \e[0m"
    read newVersion
    
    if [ -z "$newVersion" ]; then
        echo -e "\e[33mVersion not updated. Keeping the current version.\e[0m\n"
    else
        local file="$projectFullPath/version.properties"
        > "$file"
        local major=$(echo "$newVersion" | cut -d'.' -f1)
        local minor=$(echo "$newVersion" | cut -d'.' -f2)
        local patch=$(echo "$newVersion" | cut -d'.' -f3)
        local fix=$(echo "$newVersion" | cut -d'.' -f4)
        echo "major=$major" >> "$file"
        echo "minor=$minor" >> "$file"
        echo "patch=$patch" >> "$file"
        echo "fix=$fix" >> "$file"
    fi
}

function change_version_name {
    local projectFullPath=$1

    echo -n -e "\e[33m> versionName [$name](or just press ENTER to skip): \e[0m"
    read newVersionName

    if [ -z "$newVersionName" ]; then
        echo -e "\e[33mVersion not updated. Keeping the current version.\e[0m\n"
    else
        local file="$projectFullPath/build.gradle"
        local line=$(grep -n "^versionName " "$file" | cut -d ":" -f1)
        sed -i "${line}s/versionName \".*./versionName \"$newVersionName\"/g" "$file"
    fi
}

function change_version_by_project_name {
    local projectFullPath=$1
    local projectPathSubFolder=$2
    local name=$3
    local projectGradlePath=$(get_build_gradle_subfolder_path $projectPathSubFolder)

    echo -e "\n\n\e[1mModifying [$name]\e[0m"
    if [ "$name" = "bees-android" ]; then
        change_version_name "$projectFullPath$projectGradlePath"
        change_dependency_version "$projectFullPath$projectGradlePath" "$orchestratorRef"
    elif [ "$name" = "account-android" ]; then
        change_version_name "$projectFullPath$accountOrchestratorGradlePath"

        menu_change_implementation_version "$projectFullPath$accountOrchestratorGradlePath"
        menu_change_implementation_version "$projectFullPath$sampleGradlePath"
    elif [ "$name" = "b2b-mobile-android-tickets" ]; then
        change_version_name "$projectFullPath$b2bMobileTicketsCrsGradlePath"

        menu_change_implementation_version "$projectFullPath$b2bMobileTicketsBeesAdapterGradlePath"
        menu_change_implementation_version "$projectFullPath$b2bMobileTicketsCrsGradlePath"
    elif [ "$name" = "bees-account-info-android" ]; then
        change_version_name "$projectFullPath$beesAccountInfoGradlePath"

        menu_change_implementation_version "$projectFullPath$beesAccountInfoGradlePath"
        menu_change_implementation_version "$projectFullPath$sampleGradlePath"
    elif [ "$name" = "bees-account-selection-android" ]; then
        change_version_name "$projectFullPath$beesAccountSelectionGradlePath"

        menu_change_implementation_version "$projectFullPath$beesAccountSelectionGradlePath"
        menu_change_implementation_version "$projectFullPath$sampleGradlePath"
    elif [ "$name" = "bees-browse-android" ]; then
        change_version_ext_block "$projectFullPath"
    elif [ "$name" = "bees-cart-checkout-android" ]; then
        change_version_ext_block "$projectFullPath"
    elif [ "$name" = "bees-rio-android" ]; then
        change_version_properties "$projectFullPath$beesRioGradlePath"
        menu_change_implementation_version "$projectFullPath$appGradlePath"
    elif [ "$name" = "deliver-access-control-android" ]; then
        change_version_properties "$projectFullPath$deliverAccessControlGradlePath"
        menu_change_implementation_version "$projectFullPath$deliverAccessControlGradlePath"
    elif [ "$name" = "deliver-analytics-android" ]; then
        change_version_properties "$projectFullPath$deliverAnalyticsGradlePath"
    elif [ "$name" = "deliver-android" ]; then
        change_version_properties "$projectFullPath$appGradlePath"
    elif [ "$name" = "deliver-inventory-validation-android" ]; then
        change_version_properties "$projectFullPath$deliverInventoryValidationGradlePath"
    elif [ "$name" = "deliver-pix-android" ]; then
        change_version_properties "$projectFullPath$deliverPixGradlePath"

        menu_change_implementation_version "$projectFullPath$deliverPixGradlePath"
        menu_change_implementation_version "$projectFullPath$appGradlePath"
    elif [ "$name" = "deliver-pricing-engine-android" ]; then
        change_version_properties "$projectFullPath$deliverPricingEngineGradlePath"
        
        menu_change_implementation_version "$projectFullPath$appGradlePath"
        menu_change_implementation_version "$projectFullPath$deliverPricingEngineGradlePath"
    elif [ "$name" = "deliver-questionnaire-android" ]; then
        change_version_properties "$projectFullPath$deliverQuestionnaireGradlePath"

        menu_change_implementation_version "$projectFullPath$deliverQuestionnaireGradlePath"
        menu_change_implementation_version "$projectFullPath$appGradlePath"
    elif [ "$name" = "deliver-route-optimizer-android" ]; then
        change_version_properties "$projectFullPath$deliverRouteOptimizerGradlePath"

        menu_change_implementation_version "$projectFullPath$deliverRouteOptimizerGradlePath"
        menu_change_implementation_version "$projectFullPath$appGradlePath"
    elif [ "$name" = "deliver-sdk-android" ]; then
        change_version_properties "$projectFullPath$deliverSdkNetworkGradlePath"
        change_version_properties "$projectFullPath$appGradlePath"
    elif [ "$name" = "deliver-tour-android" ]; then
        change_version_properties "$projectFullPath$deliverTourGradlePath"
    elif [ "$name" = "tapwiser-android" ]; then
        change_version_name "$projectFullPath$tapwiserAndroidFuzzNetworkGradlePath"

        menu_change_implementation_version "$projectFullPath$tapwiserAndroidFuzzNetworkGradlePath"
        menu_change_implementation_version "$projectFullPath$tapwiserAndroidFuzzParserGradlePath"
        menu_change_implementation_version "$projectFullPath$tapwiserAndroidFuzzReflectionGradlePath"
        menu_change_implementation_version "$projectFullPath$tapwiserAndroidFuzzVolleyExecutorGradlePath"
        menu_change_implementation_version "$projectFullPath$tapwiserAndroidLifeCycleGradlePath"
        menu_change_implementation_version "$projectFullPath$tapwiserAndroidSdkGradlePath"
    else
        change_version_name "$projectFullPath$projectGradlePath"
        menu_change_implementation_version "$projectFullPath$projectGradlePath"
    fi
}

function find_project_folder_path_by_project_name {
    local folderNameTarget=$1

    local listFolder=$(find /home -type d -name "$folderNameTarget" -print0 2>/dev/null | xargs -0 printf "%s\n")
    if [ -z "$listFolder" ]; then
        echo -e "\n\e[33mFolder not found.\e[0m"
        exit 1
    elif [ $(echo "$listFolder" | wc -l) -eq 1 ]; then
        projPath="$listFolder"
    else
        echo -e "\e[1mMore than 1 folder was found\e[0m"
        i=1
        IFS=$'\n'
        for folder in $listFolder; do
            echo "[$i] $folder"
            ((i++))
        done

        echo -n -e "\n\e[33m> Select the correct path to follow: \e[0m"
        read optionChosen

        folderPath=""
        y=1
        for folder in $listFolder; do
            if [ $y = $optionChosen ];then
                folderPath=$folder
            fi
            ((y++))
        done

        projPath="$folderPath"
    fi
}

function generate_artifacts {
    for number in $(echo "$listProjectChosen" | tr ',' ' '); do
        local index=$((number - 1))
        local projectPathSubFolder="${listProjectName[index]}"
        local projectRootName=$(get_project_name "$projectPathSubFolder")

        printf '\n\e[3mPlease, wait...\nLooking for the folder name '\''%s'\'' in your system...\e[0m\n\n' "$projectRootName"
        find_project_folder_path_by_project_name "$projectRootName"

        local name=$(basename "$projPath")
        local gradlePath=$(get_build_gradle_subfolder_path "$projectPathSubFolder")
        
        run_gradle "$projPath" "$gradlePath" "$name"
    done
}

function input_new_version_name {
    read -p $'\e[33m> Project Numbers: \e[0m' listProjects
    listProjectChosen=$listProjects

    for number in $(echo "$listProjects" | tr ',' ' '); do
        local index=$((number-1))
        local projectPathSubFolder="${listProjectName[index]}"
        local projectRootName=$(get_project_name "$projectPathSubFolder")

        printf '\n\e[3mPlease, wait... Looking for the folder name '\''%s'\''..\e[0m\n\n' "$projectRootName"
        find_project_folder_path_by_project_name "$projectRootName"

        local name=$(basename "$projPath")
        local gradlePath=$(get_build_gradle_subfolder_path "$projectPathSubFolder")
    
        run_specs "$projPath" "$name"
        change_version_by_project_name "$projPath" "$projectPathSubFolder" "$name"
    done
}

function menu_show_list_projects {
    echo -e "\e[1mChoose your projects, IN SEQUENCE, separated by comma\e[0m"
    echo -e "e.g: \e[1m4,2,3\e[0m"
    for i in "${!listProjectName[@]}"; do
        echo "[$((i+1))] $(get_project_name "${listProjectName[$i]}")"
    done
    echo
}

function show_bye_bees_banner {
    echo -e "\n\e[33m===== Thank you, for using it! ===================================================================\e[0m"
    bees_banner
    echo -e "\e[33m===================================================================================== See ya! ====\e[0m\n\n"
}

function show_welcome_bees_banner {
    echo -e "\n\e[33m===== Welcome to... ==============================================================================\e[0m"
    bees_banner
    echo -e "\e[33m================================================================================= version 1.0 ====\e[0m\n\n"
}

function bees_banner {
    echo -e "\e[33m==================================================================================================\e[0m"
    echo -e "\e[33m=====                                         =======                                        =====\e[0m"
    echo -e "\e[33m=====    ======   =======  =======  =======   =======              .' '.            __       =====\e[0m"
    echo -e "\e[33m=====    ==   ==  ===      ===      =====     =======     .        .   .           (__\_     =====\e[0m"
    echo -e "\e[33m=====    ======   =======  =======      ===   =======      .         .         . -{{_(|8)    =====\e[0m"
    echo -e "\e[33m=====    ==   ==  ===      ===          ===   =======        ' .  . ' ' .  . '     (__/      =====\e[0m"
    echo -e "\e[33m=====    ======   =======  =======  =======   =======                                        =====\e[0m"
    echo -e "\e[33m=====                                         =======                                        =====\e[0m"
    echo -e "\e[33m==================================================================================================\e[0m"
}

show_welcome_bees_banner
menu_show_list_projects
input_new_version_name
create_menu_build_apk
generate_artifacts
run_adb_install
show_bye_bees_banner