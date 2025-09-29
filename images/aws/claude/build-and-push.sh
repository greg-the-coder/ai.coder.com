USE_SUDO=""
DOCKER_FILE=${1:-Dockerfile.noble}
IMAGE_NAME=${2:-claude-ws}
IMAGE_TAG=${3:-latest}
AWS_ACCOUNT_ID=${4:-}
AWS_REGION=${5:-us-east-2}
NO_CACHE="" # "--no-cache"

if ! docker ps >/dev/null 2>&1; then
    if ! sudo docker ps >/dev/null 2>&1; then
        echo "ERROR: Unable to run `docker`. Is the Docker Daemon running?"
        return 1 ;
    fi
    USE_SUDO="sudo"
fi

aws ecr get-login-password --region $AWS_REGION | \
    "$USE_SUDO" docker login \
        --username AWS \
        --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

"$USE_SUDO" docker build \
    --platform=linux/amd64 \
    -f $DOCKER_FILE \
    -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$IMAGE_TAG \
    --build-arg CLAUDE_CODE_VER=latest \
    --build-arg PLAYWRIGHT_VER=1.0.1 \
    --build-arg DESKTOP_COMMANDER_VER=0.1.19 \
    --build-arg HTTP_SERVER_VER=14.1.1 \
    $NO_CACHE .

read -p "Confirm to push '$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$IMAGE_TAG' (Y/N): " confirm && \
    [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || return 2 ;

"$USE_SUDO" docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_NAME:$IMAGE_TAG