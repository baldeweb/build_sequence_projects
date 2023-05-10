#!/bin/bash

projectPath=""
buildVariantTarget=""
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
    "name=UAT#code=Uat"
)

listProjectName=(
    "access-management-android/accessmanagement-iam"
    "account-android"
    "bees-android/bees-actions"
    "bees-customer-services-android/customer_services"
)

#   Project @aar reference
customerServicesRef="implementation \"com.abinbev:customer_services:"
orchestratorRef="orchestratorVersion" 

#   APK generated root path
rootPathApkGenerated="/home/wallace/Documents/bees-android/app/build/outputs/apk/"

#   Projects with sub folders
accountSampleGradlePath="/sample-app"
accountOrchestratorGradlePath="/features/orchestrator"

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
    countryName=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    countryCode=$(echo "$2" | tr '[:upper:]' '[:lower:]')
    envCode=$(echo "$3" | tr '[:upper:]' '[:lower:]')
    apkPath="$rootPathApkGenerated$countryCode/$envCode/app-$countryCode-$envCode.apk"
    appPackageName="com.abinbev.android.tapwiser.bees"

    countryCode=$(to_lowercase $countryCode)
    countryName=$(first_letter_uppercase $countryName)

    ./gradlew -Dorg.gradle.jvmargs=-Xmx1536m -XX:MaxPermSize=3072m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8-
    ./gradlew clean
    ./gradlew :app:assemble$2$3

    adb uninstall "$appPackageName$countryName.$countryCode"
    adb install "$apkPath"
    
    # To enable debug logging run
    adb shell setprop log.tag.FA VERBOSE
    
    # To enable faster debug mode event logging run:
    adb shell setprop debug.firebase.analytics.app "$appPackageName$countryName.$countryCode"

    clear
    show_bees_banner

    echo -e "\e[1m\e[33mPROCESS COMPLETED WITH TOTAL SUCCESS! BzZzzZzzz...\e[0m"
    echo -e "\e[3m(A bug free version... I hope...)\e[0m\n"
    echo -e "\e[1mNow, open your app manually and enjoy it! \(^^)/ \e[0m"

    exit 0
}

function create_menu_build_apk {
    countryCode=""
    envCode=""

    # Country
    clear
    show_countries
    echo -n -e "\e[33m> Choose a Country: \e[0m"
    read countryChosen
    countryCode=$(get_country_code_by_option $countryChosen)
    countryName=$(get_country_name_by_option $countryChosen)

    # Environments
    show_environments
    echo -n -e "\n\e[33m> Choose a Environment: \e[0m"
    read envChosen
    envCode=$(get_environment_code_by_option $envChosen)
    
    run_adb_install "$countryName" "$countryCode" "$envCode"
}

#function setup_sit_environment { }

function show_environments {
    echo -e "\n\n\e[1mLIST OF ENVIRONMENTS\e[0m"
    index=0
    for item in "${listEnvironments[@]}"
    do
        index=$(($index+1))
        name=$(extract_name $item)
        echo "[$index] $name"
    done
}

function show_countries {
    echo -e "\e[1mLIST OF COUNTRIES\e[0m"

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
    optionChosen=$1
    name=""

    index=0
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
    optionChosen=$1
    code=""

    index=0
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
    input="$1"
    code=$(echo "$input" | grep -oP "(?<=#code=).*")
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
    path=$1
    modulePath=$2
    name=$3
    
    clear
    echo -e "\e[1m\e[32m########## RUNNING: [$name] ##########\e[0m"

    cd $path
    ./gradlew prepareKotlinBuildScriptModel
    ./gradlew compileDebugKotlin
    ./gradlew sync

    if [ "$name" = "bees-android" ]; then
        ./gradlew clean
        create_menu_build_apk "$path" "$modulePath" "$name"
    elif [ "$name" = "account-android" ]; then 
        moduleName=$(echo $modulePath$OrchestratorGradlePath | grep -oE '[^/]+$' | awk '{print $1}')
        echo "2 ### MODULE NAME: $moduleName"

        ./gradlew :orchestrator:clean
        ./gradlew :orchestrator:build
        ./gradlew -Dorg.gradle.jvmargs=-Xmx1536m -XX:MaxPermSize=3072m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8-
        ./gradlew :orchestrator:assemble
        ./gradlew :orchestrator:publishToMavenLocal
    else
        moduleName=$(echo $modulePath | grep -oE '[^/]+$' | awk '{print $1}')
        echo "3 ### MODULE NAME: $moduleName"

        ./gradlew :$moduleName:clean
        ./gradlew :$moduleName:build
        ./gradlew -Dorg.gradle.jvmargs=-Xmx1536m -XX:MaxPermSize=3072m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8 build
        ./gradlew :$moduleName:clean
        ./gradlew :$moduleName:assemble
        ./gradlew :$moduleName:publishToMavenLocal
    fi
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
        echo -e "\e[32mBranch 'MASTER' chosen.\e[0m"
    else
        echo -e "\e[32mBranch $specsBranchName chosen.\e[0m"
    fi
    echo -e "\n\e[3mPlease wait... Running specs routines...\e[0m\n"

    cd "$pathSpecs"
    git fetch
    git checkout $specsBranchName
    git reset --hard origin/$specsBranchName
    cd ..

    echo -e "\e[1m\e[32mspecs routines: Success ✓\e[0m\n"
}

function change_dependency_version {
    local gradleFilePath="$1/build.gradle"
    local dependencyRef=$2
    local name=$(get_dependency_name $dependencyRef)

    echo -n -e "\e[33m> dependency version of [${name#*/}]: \e[0m"
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

function change_implementation_project_version {
    gradleFilePath=$1
    projectRef=$2
    newVersion=$3

    newLine="$projectRef$newVersion\""
    file="$gradleFilePath/build.gradle"

    line=$(grep -n "^$projectRef" "$file" | cut -d ":" -f1)

    sed -i "${line}s/$projectRef.*/$newLine/g" "$file"
}

function change_version_name {
    projectFullPath=$1

    echo -n -e "\e[33m> versionName [$name]: \e[0m"
    read newVersionName

    if [ -z "$newVersionName" ]; then
        echo -e "\e[33m> Version not updated. Keeping the current version.\e[0m"
    else
        file="$projectFullPath/build.gradle"
        line=$(grep -n "^versionName " "$file" | cut -d ":" -f1)
        sed -i "${line}s/versionName \".*./versionName \"$newVersionName\"/g" "$file"
    fi
}

function treat_account_android_subfolder {
    projectFullPath=$1

    # sample-app
    gradleFullPath="$projectFullPath$accountSampleGradlePath"
    echo -n -e "\e[33m> implementation project version: [sample-app]: \e[0m"
    read sampleAppVersionName
    versionNameTyped="$sampleAppVersionName"
    change_implementation_project_version "$gradleFullPath" "$customerServicesRef" "$sampleAppVersionName"

    # orchestrator
    gradleFullPath="$projectFullPath$accountOrchestratorGradlePath"
    echo -n -e "\e[33m> Repeat the same 'implementation project version' for [orchestrator]? (y/n):\e[0m"
    read answerRepeat

    change_version_name "$gradleFullPath"

    if [ "$answerRepeat" = "y" ]; then
        change_implementation_project_version "$gradleFullPath" "$customerServicesRef" "$versionNameTyped"
    else
        echo -n -e "\e[33m> implementation project version: [orchestrator]: \e[0m"
        read orchestratorVersionName

        change_implementation_project_version "$gradleFullPath" "$customerServicesRef" "$orchestratorVersionName"
    fi
}

function change_version_by_project_name {
    projectFullPath=$1
    projectPathSubFolder=$2
    name=$3
    projectGradlePath=$(get_build_gradle_subfolder_path $projectPathSubFolder)

    echo -e "\n\n\e[1mModifying [$name]\e[0m"
    if [ "$name" = "account-android" ]; then
        treat_account_android_subfolder "$projectFullPath$projectGradlePath" 
    elif [ "$name" = "bees-android" ]; then
        change_dependency_version "$projectFullPath$projectGradlePath" "$orchestratorRef"
    else
        change_version_name "$projectFullPath$projectGradlePath"
    fi
}

function find_project_folder_path_by_project_name {
    local folderNameTarget=$1

    local listFolder=$(find / -type d -name "$folderNameTarget" -print0 2>/dev/null | xargs -0 printf "%s\n")
    if [ -z "$listFolder" ]; then
        echo -e "\n\e[33mFolder [$folderNameTarget] not found.\e[0m"
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

        echo -n -e "\n\e[33m> Select the correct to follow:\e[0m"
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

function input_new_version_name {
    echo -n -e "\e[33m> Project Numbers: \e[0m"
    read listProjects

    # Save current inner field separator
    OLDIFS=$IFS

    # Set inner field separator to comma
    IFS=,

    for number in $listProjects; do
        index=$(($number-1))
        local projectPathSubFolder="${listProjectName[index]}"
        local projectRootName=$(get_project_name $projectPathSubFolder)

        echo -e "\n\e[3mPlease, wait...\nI'm looking for the folder called '$projectRootName' in your system...\e[0m\n"
        find_project_folder_path_by_project_name "$projectRootName"
        name=$(echo $projPath | awk -F/ '{print $NF}')
        gradlePath=$(get_build_gradle_subfolder_path $projectPathSubFolder)

        run_specs "$projPath" "$name"
        change_version_by_project_name "$projPath" "$projectPathSubFolder" "$name"
        run_gradle "$projPath" "$gradlePath" "$name"

        echo -e "\n"
    done

    # Restore the original inner field separator
    IFS=$OLDIFS
}

function menu_show_list_projects {
    echo -e "\e[1mChoose your projects, IN SEQUENCE, separed by comma\e[0m"
    echo -e "e.g: \e[1m4,2,3\e[0m"
    for i in "${!listProjectName[@]}"; do
        index=$(($i+1))

        projName=$(get_project_name ${listProjectName[$i]})
        echo "[$index] $projName"
    done
    echo -e "\n"
}

function show_bees_banner {
    echo -e "\n"
    echo -e "\e[33m==========================================================\e[0m"
    echo -e "\e[33m========    ======   ======== ======== ========   ========\e[0m"
    echo -e "\e[33m========    ==    =  ===      ===      =====      ========\e[0m"
    echo -e "\e[33m========    =======  ======== ========     ====   ========\e[0m"
    echo -e "\e[33m========    ==    =  ===      ===          ====   ========\e[0m"
    echo -e "\e[33m========    ======   ======== ======== ========   ========\e[0m"
    echo -e "\e[33m==========================================================\e[0m"
    echo -e "\n\n"
}

show_bees_banner
menu_show_list_projects
input_new_version_name